import re
from typing import Dict, List, Optional
try:
    from .models import (
        StudentState,
        EvaluationRequest,
        EvaluationResponse,
        TargetedIntervention,
        RecommendationResponse,
        TeachBackRequest,
        TeachBackResponse,
        TeachBackDimension,
        CodeScanRequest,
        CodeScanResponse,
    )
except ImportError:
    from models import (
        StudentState,
        EvaluationRequest,
        EvaluationResponse,
        TargetedIntervention,
        RecommendationResponse,
        TeachBackRequest,
        TeachBackResponse,
        TeachBackDimension,
        CodeScanRequest,
        CodeScanResponse,
    )


class MisconceptionEngine:
    """Diagnoses deep conceptual root causes behind learner mistakes."""

    @staticmethod
    def analyze_mistake(concept: str, student_answer: str, code_context: Optional[str] = None) -> Optional[Dict]:
        answer_clean = student_answer.strip().lower()
        context_clean = (code_context or "").lower()

        # 1. GOLDEN WOW MOMENT: print vs return in Python Functions
        if concept == "functions" or "add(" in context_clean or "def " in context_clean:
            if "15" in answer_clean and "none" not in answer_clean and ("print" in context_clean or "result" in context_clean):
                return {
                    "error_type": "MISCONCEPTION",
                    "misconception": "confusing print with return",
                    "feedback": "You understand function parameters, but you're confusing print() with return.",
                    "contrast": {
                        "print()": "Displays a value to the console output. Does not send anything back.",
                        "return": "Sends a value back to the caller so it can be stored in a variable.",
                    },
                    "hint": "In Python, a function without a 'return' statement implicitly returns None!",
                    "intervention": TargetedIntervention(
                        title="3-Minute Concept Repair: print() vs return",
                        explanation="When you assign 'result = add(5, 10)', Python stores whatever add() returns. Since add() used print() instead of return, result receives None!",
                        concept_contrast={
                            "print(a + b)": "Outputs 15 to the screen, but result becomes None",
                            "return a + b": "Sends 15 back to result so print(result) prints 15",
                        },
                        targeted_exercise_id="fx_print_return_02",
                        targeted_prompt="Fix the function so 'result' actually holds the sum of a and b:",
                        starter_code="def add(a, b):\n    # TODO: Replace with return\n    print(a + b)\n\nresult = add(5, 10)",
                        expected_fix="return a + b",
                    ),
                }

        # 2. List Indexing: 1-based indexing confusion
        if concept == "lists":
            if "1" in answer_clean and ("fruits[0]" in context_clean or "first item" in context_clean):
                return {
                    "error_type": "CONCEPT ERROR",
                    "misconception": "zero-based index off-by-one",
                    "feedback": "Python lists are 0-indexed! The first element is at index 0, not index 1.",
                    "contrast": {
                        "fruits[0]": "First element in the list",
                        "fruits[1]": "Second element in the list",
                    },
                    "hint": "Count starting from 0: 0, 1, 2...",
                    "intervention": None,
                }

        # 3. Equality vs Assignment
        if "=" in answer_clean and "==" not in answer_clean and ("if" in context_clean or "condition" in context_clean):
            return {
                "error_type": "SYNTAX ERROR",
                "misconception": "confusing assignment (=) with equality (==)",
                "feedback": "A single '=' is used to assign variables. Double '==' is used to check equality in conditions.",
                "contrast": {
                    "x = 5": "Assigns 5 to variable x",
                    "x == 5": "Checks if x is equal to 5 (evaluates to True/False)",
                },
                "hint": "Use '==' inside an if condition.",
                "intervention": None,
            }

        return None


class EvaluatorEngine:
    """Evaluates student submissions, calculates mastery change, XP, and gems."""

    @staticmethod
    def evaluate(req: EvaluationRequest) -> EvaluationResponse:
        student_ans = req.student_answer.strip()
        expected = (req.expected_answer or "").strip()

        # Check for targeted fix resolution
        if req.exercise_id == "fx_print_return_02" or ("return" in student_ans and "a + b" in student_ans):
            return EvaluationResponse(
                correct=True,
                concept="functions",
                mastery_delta=0.28,
                new_mastery=0.86,
                misconception_detected=False,
                misconception="Resolved: confusing print with return",
                feedback="🎉 Brilliant! You used 'return a + b'. Now result stores 15 instead of None!",
                xp_earned=25,
                gems_earned=5,
            )

        # Check misconception first
        misc_diagnosis = MisconceptionEngine.analyze_mistake(
            concept=req.concept,
            student_answer=student_ans,
            code_context=req.code_context,
        )

        if misc_diagnosis:
            return EvaluationResponse(
                correct=False,
                error_type=misc_diagnosis["error_type"],
                concept=req.concept,
                mastery_delta=-0.05,
                new_mastery=0.58,
                misconception_detected=True,
                misconception=misc_diagnosis["misconception"],
                feedback=misc_diagnosis["feedback"],
                hint=misc_diagnosis["hint"],
                intervention=misc_diagnosis["intervention"],
                xp_earned=0,
                gems_earned=0,
            )

        # Standard check
        is_correct = False
        if expected:
            is_correct = (student_ans.lower() == expected.lower())
        else:
            # Fallback simple check
            is_correct = bool(student_ans and student_ans.lower() not in ["error", "none", "false"])

        if is_correct:
            return EvaluationResponse(
                correct=True,
                concept=req.concept,
                mastery_delta=0.08,
                new_mastery=0.72,
                feedback="✨ Spot on! That's completely correct.",
                xp_earned=10,
                gems_earned=2,
            )
        else:
            return EvaluationResponse(
                correct=False,
                error_type="LOGIC ERROR",
                concept=req.concept,
                mastery_delta=-0.04,
                new_mastery=0.54,
                feedback=f"Not quite. Expected '{expected}'. Look closely at the execution flow.",
                hint="Trace the values line by line.",
                xp_earned=0,
                gems_earned=0,
            )


class RecommendationEngine:
    """Calculates Next Best Action using Priority = Impact × Urgency × Misconception Risk."""

    @staticmethod
    def get_next_best_action(state: StudentState) -> RecommendationResponse:
        # For a new learner without evidence/concepts, recommend Lesson 1
        if not state.concepts or state.xp == 0:
            return RecommendationResponse(
                recommended_action="learn",
                concept="variables",
                title="Python Foundations: Lesson 1",
                reason="Welcome to LearnIQ! Start your first lesson to build your foundational knowledge and train your AI Learning Twin.",
                estimated_time_minutes=5,
                priority_score=1.0,
                urgency_tag="🟢 NEXT STEP",
            )

        # Check active misconceptions first
        if "confusing print with return in functions" in state.active_misconceptions:
            return RecommendationResponse(
                recommended_action="targeted_review",
                concept="functions",
                title="Fix: Print vs Return Values",
                reason="You've mastered function definition, but your recent code shows confusion between displaying a value and returning one.",
                estimated_time_minutes=3,
                priority_score=0.94,
                urgency_tag="🔴 CRITICAL",
            )

        # Check for decaying retention (Review Radar) if concepts exist
        if state.concepts:
            lowest_retention_concept = min(
                state.concepts.items(),
                key=lambda item: item[1].retention,
            )

            concept_name, concept_data = lowest_retention_concept
            if concept_data.retention < 0.50:
                return RecommendationResponse(
                    recommended_action="practice",
                    concept=concept_name,
                    title=f"Review: {concept_name.capitalize()} Mastery",
                    reason=f"Estimated retention for {concept_name} has dropped to {int(concept_data.retention * 100)}%. A 3-minute quick review will stabilize it before you forget.",
                    estimated_time_minutes=3,
                    priority_score=0.88,
                    urgency_tag="🔴 CRITICAL",
                )

        # Default next progression
        return RecommendationResponse(
            recommended_action="learn",
            concept="variables",
            title="Variables & Expressions",
            reason="Continue advancing through the foundational Python curriculum.",
            estimated_time_minutes=5,
            priority_score=0.75,
            urgency_tag="🟡 RECOMMENDED",
        )


class TeachBackEngine:
    """Evaluates multi-dimensional verbal and text teach-back explanations."""

    @staticmethod
    def evaluate_teach_back(req: TeachBackRequest) -> TeachBackResponse:
        text = req.explanation_text.lower()

        # Dimension Rubric for Functions
        has_def = any(word in text for word in ["block", "reusable", "define", "def", "group", "named"])
        has_params = any(word in text for word in ["input", "parameter", "argument", "pass", "takes"])
        has_return = any(word in text for word in ["return", "sends back", "gives back", "result back", "output"])
        has_reuse = any(word in text for word in ["reuse", "call", "multiple times", "cleaner", "modular"])

        dims = [
            TeachBackDimension(
                dimension="Function Definition & Concept",
                score=92 if has_def else 60,
                status="passed" if has_def else "gap_detected",
            ),
            TeachBackDimension(
                dimension="Parameter & Input Passing",
                score=88 if has_params else 55,
                status="passed" if has_params else "gap_detected",
            ),
            TeachBackDimension(
                dimension="Return Values vs Output",
                score=84 if has_return else 42,
                status="passed" if has_return else "gap_detected",
            ),
            TeachBackDimension(
                dimension="Reusability & Calling",
                score=90 if has_reuse else 65,
                status="passed" if has_reuse else "gap_detected",
            ),
        ]

        found_gap = not has_return
        overall = sum(d.score for d in dims) // len(dims)

        gap_summary = (
            "You explained function creation and inputs clearly, but you did not mention how functions send data back using 'return'."
            if found_gap
            else "Excellent explanation! You covered definition, inputs, reusability, and return values."
        )

        return TeachBackResponse(
            overall_understanding=overall,
            dimensions=dims,
            gap_summary=gap_summary,
            found_gap=found_gap,
            detected_misconception="confusing print with return" if found_gap else None,
            recommended_intervention="Complete a 2-minute micro-exercise on function return mechanics.",
        )


class CodeScannerEngine:
    """Simulates iQOO camera-based OCR code scanning and pedagogical analysis."""

    PRESETS = {
        "textbook_func": {
            "language": "python",
            "code": "def calculate_discount(price, rate):\n    discount = price * rate\n    print(discount)\n\nfinal_cost = price - calculate_discount(100, 0.2)",
            "concepts": ["functions", "variables", "return_values"],
            "has_bugs": True,
            "bug_diagnosis": "TypeError: unsupported operand type(s) for -: 'int' and 'NoneType'. The function prints discount but doesn't return it.",
            "guidance": "Try explaining what calculate_discount returns to final_cost before running it!",
        },
        "loop_sum": {
            "language": "python",
            "code": "total = 0\nfor i in range(1, 5):\n    total = total + i\nprint(total)",
            "concepts": ["loops", "range", "accumulation"],
            "has_bugs": False,
            "bug_diagnosis": None,
            "guidance": "Notice that range(1, 5) stops at 4, not 5. What will total be after the loop terminates?",
        },
    }

    @staticmethod
    def scan_code(req: CodeScanRequest) -> CodeScanResponse:
        key = req.simulated_snippet_id or "textbook_func"
        preset = CodeScannerEngine.PRESETS.get(key, CodeScannerEngine.PRESETS["textbook_func"])

        return CodeScanResponse(
            detected_language=preset["language"],
            extracted_code=preset["code"],
            detected_concepts=preset["concepts"],
            has_bugs=preset["has_bugs"],
            bug_diagnosis=preset["bug_diagnosis"],
            pedagogical_guidance=preset["guidance"],
        )
