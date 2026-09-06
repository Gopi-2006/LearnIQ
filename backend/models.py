from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field


class ConceptState(BaseModel):
    mastery: float = Field(..., ge=0.0, le=1.0)
    retention: float = Field(..., ge=0.0, le=1.0)
    confidence: float = Field(..., ge=0.0, le=1.0)
    last_practiced: Optional[str] = None
    mistake_count: int = 0
    success_count: int = 0


class StudentState(BaseModel):
    user_id: str = "user_gopi_01"
    name: str = "Gopi"
    language: str = "python"
    level: int = 3
    level_title: str = "Syntax Scout"
    xp: int = 1090
    streak: int = 7
    daily_goal_minutes: int = 10
    daily_progress_minutes: int = 8
    energy: int = 80
    max_energy: int = 100
    gems: int = 240
    concepts: Dict[str, ConceptState] = {
        "variables": ConceptState(mastery=0.92, retention=0.91, confidence=0.95, mistake_count=1, success_count=14),
        "conditions": ConceptState(mastery=0.81, retention=0.74, confidence=0.82, mistake_count=3, success_count=11),
        "loops": ConceptState(mastery=0.43, retention=0.42, confidence=0.48, mistake_count=7, success_count=5),
        "functions": ConceptState(mastery=0.58, retention=0.61, confidence=0.60, mistake_count=5, success_count=8),
        "lists": ConceptState(mastery=0.48, retention=0.52, confidence=0.50, mistake_count=6, success_count=4),
    }
    active_misconceptions: List[str] = [
        "confusing print with return in functions",
        "zero-based index out-of-range in lists",
    ]
    resolved_misconceptions: List[str] = [
        "variable re-assignment confusion",
    ]


class EvaluationRequest(BaseModel):
    exercise_id: str
    concept: str
    question_type: str  # multiple_choice, output_prediction, fill_blank, bug_fix, mini_coding, teach_back
    student_answer: str
    code_context: Optional[str] = None
    expected_answer: Optional[str] = None
    student_state: Optional[StudentState] = None


class TargetedIntervention(BaseModel):
    title: str
    explanation: str
    concept_contrast: Dict[str, str]
    targeted_exercise_id: str
    targeted_prompt: str
    starter_code: str
    expected_fix: str


class EvaluationResponse(BaseModel):
    correct: bool
    error_type: Optional[str] = None  # SYNTAX ERROR, LOGIC ERROR, CONCEPT ERROR, MISCONCEPTION, CARELESS ERROR
    concept: str
    mastery_delta: float
    new_mastery: float
    misconception_detected: bool = False
    misconception: Optional[str] = None
    feedback: str
    hint: Optional[str] = None
    intervention: Optional[TargetedIntervention] = None
    xp_earned: int = 0
    gems_earned: int = 0


class RecommendationResponse(BaseModel):
    recommended_action: str  # practice, targeted_review, learn, debug_challenge, teach_back
    concept: str
    title: str
    reason: str
    estimated_time_minutes: int
    priority_score: float
    urgency_tag: str  # 🔴 CRITICAL, 🟡 RECOMMENDED, 🟢 REINFORCE


class TeachBackDimension(BaseModel):
    dimension: str
    score: int
    status: str  # passed, gap_detected


class TeachBackRequest(BaseModel):
    concept: str
    explanation_text: str
    audio_duration_seconds: Optional[float] = None


class TeachBackResponse(BaseModel):
    overall_understanding: int
    dimensions: List[TeachBackDimension]
    gap_summary: str
    found_gap: bool
    detected_misconception: Optional[str] = None
    recommended_intervention: str


class CodeScanRequest(BaseModel):
    image_base64: Optional[str] = None
    simulated_snippet_id: Optional[str] = None


class CodeScanResponse(BaseModel):
    detected_language: str
    extracted_code: str
    detected_concepts: List[str]
    has_bugs: bool
    bug_diagnosis: Optional[str] = None
    pedagogical_guidance: str
