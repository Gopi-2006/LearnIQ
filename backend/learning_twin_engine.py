"""LearnIQ Learning Twin Engine.

Offline cognitive twin tracking student mastery (0.0 - 1.0), progression gating
(reading/concept understanding first), non-repetition locks, error diagnosis,
and alternative analogy re-teaching.
"""

from typing import Dict, List, Any, Optional
from pydantic import BaseModel, Field
try:
    from .document_parser import curriculum_parser, LessonNode
    from .ai_prompt_templates import extract_clean_json
except ImportError:
    from document_parser import curriculum_parser, LessonNode
    from ai_prompt_templates import extract_clean_json


class TopicMastery(BaseModel):
    topic_id: str
    mastery_score: float = Field(0.1, ge=0.0, le=1.0)
    retention_score: float = Field(0.5, ge=0.0, le=1.0)
    is_read_completed: bool = False
    is_mastered: bool = False
    attempt_count: int = 0
    mistake_count: int = 0
    consecutive_correct: int = 0
    last_error_type: Optional[str] = None
    last_error_explanation: Optional[str] = None


class CognitiveProfile(BaseModel):
    user_id: str = "user_offline_01"
    name: str = "Alex"
    current_stage: int = 1
    current_stage_name: str = "Foundations"
    topics: Dict[str, TopicMastery] = {}
    completed_topic_ids: List[str] = []
    active_re_teaching_topic: Optional[str] = None


class LearningTwinEngine:
    """Core offline intelligence engine managing student cognitive state."""

    def __init__(self):
        self.profile = CognitiveProfile()
        self._init_default_twin_state()

    def _init_default_twin_state(self) -> None:
        """Initialize learning twin topics from the parsed curriculum."""
        nodes = curriculum_parser.load_cached_or_build()
        for tid in nodes.keys():
            self.profile.topics[tid] = TopicMastery(
                topic_id=tid,
                mastery_score=0.10,
                retention_score=0.50,
                is_read_completed=False,
                is_mastered=False,
            )

    # =========================================================================
    # 1. PROGRESSION CONTROL & READING GATING
    # =========================================================================

    def mark_reading_completed(self, topic_id: str) -> Dict[str, Any]:
        """Student has read and reviewed the core concept and analogy.

        Enforces KEY REQUIREMENT: Lesson reading first before practice!
        """
        if topic_id not in self.profile.topics:
            self.profile.topics[topic_id] = TopicMastery(topic_id=topic_id)

        topic = self.profile.topics[topic_id]
        topic.is_read_completed = True
        topic.mastery_score = max(topic.mastery_score, 0.35)

        node = curriculum_parser.curriculum_nodes.get(topic_id)
        return {
            "status": "reading_unlocked_practice",
            "topic_id": topic_id,
            "title": node.title if node else topic_id,
            "message": "Concept internalized! Practice exercises and Parsons/BugHunter are now unlocked.",
            "next_step": "practice_questions",
        }

    def can_attempt_practice(self, topic_id: str) -> bool:
        """Enforces that student must complete lesson reading before practice."""
        topic = self.profile.topics.get(topic_id)
        if not topic:
            return False
        return topic.is_read_completed

    def get_next_progression_node(self) -> Optional[Dict[str, Any]]:
        """Returns the next non-completed topic in linear sequence.

        Enforces KEY REQUIREMENT: Completed topics MUST NOT repeat in standard progression.
        """
        nodes = curriculum_parser.load_cached_or_build()

        for topic_id, node in nodes.items():
            # Skip if already marked completed/mastered
            if topic_id in self.profile.completed_topic_ids:
                continue

            topic_state = self.profile.topics.get(topic_id)
            if topic_state and topic_state.is_mastered:
                continue

            # Check prerequisites
            prereqs_satisfied = all(
                p in self.profile.completed_topic_ids for p in node.prerequisites
            )
            if not prereqs_satisfied and node.prerequisites:
                continue

            # Found the active next node!
            return {
                "topic_id": node.topic_id,
                "title": node.title,
                "stage": node.stage,
                "stage_name": node.stage_name,
                "needs_reading": not (topic_state and topic_state.is_read_completed),
                "core_concept": node.core_concept,
                "analogy": node.analogy,
                "code_examples": node.code_examples,
                "exercises_available": len(node.exercises),
            }

        return None

    # =========================================================================
    # 2. EVALUATION & ERROR-DRIVEN RE-TEACHING
    # =========================================================================

    def evaluate_submission(
        self,
        topic_id: str,
        exercise_id: str,
        student_answer: str,
        expected_answer: str,
        code_context: Optional[str] = None,
        elapsed_seconds: float = 15.0,
    ) -> Dict[str, Any]:
        """Evaluates student submission, tracks cognitive changes, and triggers re-teaching if needed."""
        # 1. Gate: ensure reading stage was completed
        if not self.can_attempt_practice(topic_id):
            return {
                "is_correct": False,
                "gating_alert": True,
                "message": "Lesson Execution First: You must complete the concept reading stage before attempting questions!",
                "suggest_reading_topic": topic_id,
            }

        topic = self.profile.topics.get(topic_id)
        if not topic:
            topic = TopicMastery(topic_id=topic_id, is_read_completed=True)
            self.profile.topics[topic_id] = topic

        topic.attempt_count += 1
        is_correct = student_answer.strip().lower() == expected_answer.strip().lower()

        if is_correct:
            topic.consecutive_correct += 1
            # Speed & accuracy mastery delta
            speed_bonus = 0.05 if elapsed_seconds < 20 else 0.02
            topic.mastery_score = min(1.0, topic.mastery_score + 0.20 + speed_bonus)
            topic.retention_score = min(1.0, topic.retention_score + 0.10)

            # Check mastery threshold (0.85) -> Non-repetition lock
            if topic.mastery_score >= 0.85 and topic.consecutive_correct >= 2:
                topic.is_mastered = True
                if topic_id not in self.profile.completed_topic_ids:
                    self.profile.completed_topic_ids.append(topic_id)

            return {
                "is_correct": True,
                "topic_id": topic_id,
                "new_mastery": round(topic.mastery_score, 2),
                "is_mastered": topic.is_mastered,
                "consecutive_correct": topic.consecutive_correct,
                "feedback": "Correct! Your cognitive twin updated with verified understanding.",
                "re_teaching_required": False,
            }

        # -------------------------------------------------------------
        # ERROR CASE: ERROR-DRIVEN RE-TEACHING TRIGGER
        # -------------------------------------------------------------
        topic.consecutive_correct = 0
        topic.mistake_count += 1
        topic.mastery_score = max(0.1, topic.mastery_score - 0.15)
        topic.retention_score = max(0.2, topic.retention_score - 0.08)

        # Classify the error pattern
        error_type, mistake_explanation = self._classify_mistake(
            topic_id, student_answer, expected_answer, code_context
        )
        topic.last_error_type = error_type
        topic.last_error_explanation = mistake_explanation

        # Build easy alternative re-teaching analogy
        reteaching_package = self._build_reteaching_package(
            topic_id, error_type, mistake_explanation
        )

        return {
            "is_correct": False,
            "topic_id": topic_id,
            "new_mastery": round(topic.mastery_score, 2),
            "is_mastered": False,
            "error_type": error_type,
            "mistake_explanation": mistake_explanation,
            "re_teaching_required": True,
            "reteaching_package": reteaching_package,
        }

    def _classify_mistake(
        self,
        topic_id: str,
        student_answer: str,
        expected_answer: str,
        code_context: Optional[str],
    ) -> tuple[str, str]:
        """Rules-based offline error classifier diagnosing why the mistake occurred."""
        s = student_answer.lower()
        exp = expected_answer.lower()
        ctx = (code_context or "").lower()

        # 1. Return vs Print confusion
        if "return" in topic_id or "print" in ctx:
            if "print" in s and "return" in exp:
                return (
                    "return_vs_print",
                    "You confused 'print' with 'return'. print only shows text on screen and yields None. return gives the result to your program.",
                )
            if "none" in exp and "none" not in s:
                return (
                    "return_vs_print",
                    "Functions without a return statement implicitly return None in memory, even if they print values.",
                )

        # 2. Zero-based indexing / Off-by-one
        if "index" in topic_id or "lists" in topic_id or "[" in ctx:
            if "3" in s and "2" in exp:
                return (
                    "off_by_one",
                    "Off-by-one bounds error. Python lists are 0-indexed: index 0 is first, index 1 is second, index 2 is third. Index 3 is out of bounds for 3 elements!",
                )
            if "1" in s and "0" in exp:
                return (
                    "off_by_one",
                    "Remember that the first element in Python always sits at index 0, not 1.",
                )

        # 3. Scope & Indentation
        if "indent" in s or "scope" in topic_id or "    " in ctx:
            return (
                "scope_mismatch",
                "Indentation scope mismatch: Statements inside functions or loops must be indented exactly 4 spaces.",
            )

        # 4. Syntax error
        if "=" in s and "==" in exp:
            return (
                "syntax_error",
                "Used single '=' (assignment) instead of double '==' (equality comparison).",
            )

        # Default fallback
        return (
            "logic_discrepancy",
            f"Output evaluated to '{student_answer}', but expected algorithmic result was '{expected_answer}'.",
        )

    def _build_reteaching_package(
        self, topic_id: str, error_type: str, mistake_explanation: str
    ) -> Dict[str, Any]:
        """Constructs an alternative tangible analogy to explain the concept in simpler terms before re-testing."""
        node = curriculum_parser.curriculum_nodes.get(topic_id)
        topic_title = node.title if node else topic_id

        # Custom tailored analogies by error type
        if error_type == "return_vs_print":
            analogy = {
                "headline": "Vending Machine vs Loudspeaker",
                "analogy_text": (
                    "Imagine buying a snack. print() is like a loudspeaker announcing 'Here is a chocolate bar!' but hands you nothing. "
                    "return is the tray that actually drops the chocolate into your hands so you can eat it."
                ),
                "visual_cue": "📢 print = announcement | 🍫 return = real item in hand",
            }
            retest_exercise = {
                "exercise_id": "retest_ret_01",
                "prompt": "Which function allows us to store the calculated answer in a variable?",
                "code_snippet": "def get_gold():\n    ______ 100\n\nbag = get_gold()",
                "options": ["return", "print", "display"],
                "correct_option_index": 0,
                "explanation": "return passes 100 into the variable bag.",
            }
        elif error_type == "off_by_one":
            analogy = {
                "headline": "The Distance from Starting Tape",
                "analogy_text": (
                    "Think of list indices as footsteps away from the starting line. "
                    "The very first runner is 0 steps away. The third runner is only 2 steps away!"
                ),
                "visual_cue": "🏁 [0] 1st runner | [1] 2nd runner | [2] 3rd runner",
            }
            retest_exercise = {
                "exercise_id": "retest_idx_01",
                "prompt": "What is the index of the first item in scores = [95, 88, 72]?",
                "options": ["0", "1", "-0"],
                "correct_option_index": 0,
                "explanation": "List indexing always starts at 0.",
            }
        else:
            analogy = node.analogy if node else {
                "headline": "Step-by-step logic",
                "analogy_text": "Code executes in single linear sequence from top to bottom.",
                "visual_cue": "⬇️ Line 1 -> Line 2 -> Line 3",
            }
            retest_exercise = {
                "exercise_id": f"retest_{topic_id}_retry",
                "prompt": f"Review {topic_title}: Choose the valid construct.",
                "code_snippet": node.code_examples[0] if (node and node.code_examples) else "x = 10",
                "options": ["Option A (Correct)", "Option B (Incorrect)", "Option C (SyntaxError)"],
                "correct_option_index": 0,
                "explanation": "Follow the syntax rules outlined in the core concept.",
            }

        return {
            "topic_id": topic_id,
            "topic_title": topic_title,
            "mistake_diagnosis": mistake_explanation,
            "easy_analogy": analogy,
            "step_by_step_breakdown": [
                f"1. Identify: {error_type.replace('_', ' ').title()}",
                "2. Apply the analogy: Think of how memory holds the value",
                "3. Verify line by line before submitting",
            ],
            "retest_exercise": retest_exercise,
        }

    # =========================================================================
    # 3. WEAKNESS & STAGE DIAGNOSTICS
    # =========================================================================

    def get_stage_diagnostics(self) -> Dict[str, Any]:
        """Surfaces the user's active stage and explicitly highlights weak topics."""
        weak_topics = []
        strong_topics = []
        total_score = 0.0
        count = 0

        for tid, t in self.profile.topics.items():
            total_score += t.mastery_score
            count += 1
            node = curriculum_parser.curriculum_nodes.get(tid)
            title = node.title if node else tid

            if t.mastery_score < 0.60 or t.mistake_count > 2:
                weak_topics.append({
                    "topic_id": tid,
                    "topic_name": title,
                    "score": round(t.mastery_score, 2),
                    "diagnosis_message": (
                        f"You are weak in {title} (mastery: {int(t.mastery_score * 100)}%). "
                        f"Last issue: {t.last_error_type or 'low retention'}."
                    ),
                })
            elif t.mastery_score >= 0.80:
                strong_topics.append(title)

        overall = round(total_score / max(1, count), 2)

        # Compute active stage
        if len(self.profile.completed_topic_ids) >= 4:
            self.profile.current_stage = 3
            self.profile.current_stage_name = "Modular Programming"
        elif len(self.profile.completed_topic_ids) >= 2:
            self.profile.current_stage = 2
            self.profile.current_stage_name = "Collections & Flow"
        else:
            self.profile.current_stage = 1
            self.profile.current_stage_name = "Foundations"

        recommendation = "All systems green! Proceed to the next curriculum unit."
        if weak_topics:
            top_weak = weak_topics[0]
            recommendation = (
                f"Stage {self.profile.current_stage}: {self.profile.current_stage_name} - "
                f"Attention needed: {top_weak['diagnosis_message']}"
            )

        return {
            "current_stage": self.profile.current_stage,
            "stage_title": f"Stage {self.profile.current_stage}: {self.profile.current_stage_name}",
            "overall_mastery": overall,
            "completed_topics_count": len(self.profile.completed_topic_ids),
            "completed_topic_ids": self.profile.completed_topic_ids,
            "weak_topics": weak_topics,
            "strong_topics": strong_topics,
            "actionable_recommendation": recommendation,
        }


# Global singleton instance
learning_twin_engine = LearningTwinEngine()
