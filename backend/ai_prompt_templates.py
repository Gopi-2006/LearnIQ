"""Rigid JSON-schema prompt templates and validators for LearnIQ offline AI engine.

Enforces zero-failure JSON contracts for local GGUF / llama-cpp-python execution
and local rule engines.
"""

import json
import re
from typing import Any, Dict, Optional

# =====================================================================
# 1. JSON SCHEMA CONTRACTS
# =====================================================================

EVALUATION_SCHEMA: Dict[str, Any] = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "EvaluationResult",
    "type": "object",
    "required": [
        "is_correct",
        "error_type",
        "mistake_explanation",
        "underlying_misconception",
        "mastery_delta",
        "suggest_reteaching",
    ],
    "properties": {
        "is_correct": {"type": "boolean"},
        "error_type": {
            "type": "string",
            "enum": [
                "none",
                "syntax_error",
                "off_by_one",
                "scope_mismatch",
                "return_vs_print",
                "type_mismatch",
                "index_out_of_bounds",
                "uninitialized_variable",
                "logic_inversion",
            ],
        },
        "mistake_explanation": {"type": "string"},
        "underlying_misconception": {"type": "string"},
        "mastery_delta": {"type": "number", "minimum": -0.5, "maximum": 0.5},
        "suggest_reteaching": {"type": "boolean"},
    },
}

RETEACHING_SCHEMA: Dict[str, Any] = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "ReteachingPayload",
    "type": "object",
    "required": [
        "topic_id",
        "topic_title",
        "mistake_diagnosis",
        "easy_analogy",
        "step_by_step_breakdown",
        "retest_exercise",
    ],
    "properties": {
        "topic_id": {"type": "string"},
        "topic_title": {"type": "string"},
        "mistake_diagnosis": {"type": "string"},
        "easy_analogy": {
            "type": "object",
            "required": ["headline", "analogy_text", "visual_cue"],
            "properties": {
                "headline": {"type": "string"},
                "analogy_text": {"type": "string"},
                "visual_cue": {"type": "string"},
            },
        },
        "step_by_step_breakdown": {
            "type": "array",
            "items": {"type": "string"},
        },
        "retest_exercise": {
            "type": "object",
            "required": [
                "exercise_id",
                "prompt",
                "code_snippet",
                "options",
                "correct_option_index",
                "explanation",
            ],
            "properties": {
                "exercise_id": {"type": "string"},
                "prompt": {"type": "string"},
                "code_snippet": {"type": "string"},
                "options": {"type": "array", "items": {"type": "string"}},
                "correct_option_index": {"type": "integer"},
                "explanation": {"type": "string"},
            },
        },
    },
}

DOUBT_ANSWER_SCHEMA: Dict[str, Any] = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "DoubtResponse",
    "type": "object",
    "required": [
        "question",
        "direct_answer",
        "code_example",
        "chami_tip",
        "source_citations",
        "search_mode",
    ],
    "properties": {
        "question": {"type": "string"},
        "direct_answer": {"type": "string"},
        "code_example": {"type": "string"},
        "chami_tip": {"type": "string"},
        "source_citations": {
            "type": "array",
            "items": {"type": "string"},
        },
        "search_mode": {
            "type": "string",
            "enum": ["offline_local_assets", "online_web_search", "hybrid"],
        },
    },
}

STAGE_DIAGNOSTICS_SCHEMA: Dict[str, Any] = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "StageDiagnostics",
    "type": "object",
    "required": [
        "current_stage",
        "stage_title",
        "overall_mastery",
        "weak_topics",
        "strong_topics",
        "actionable_recommendation",
    ],
    "properties": {
        "current_stage": {"type": "integer"},
        "stage_title": {"type": "string"},
        "overall_mastery": {"type": "number"},
        "weak_topics": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["topic_id", "topic_name", "score", "diagnosis_message"],
                "properties": {
                    "topic_id": {"type": "string"},
                    "topic_name": {"type": "string"},
                    "score": {"type": "number"},
                    "diagnosis_message": {"type": "string"},
                },
            },
        },
        "strong_topics": {"type": "array", "items": {"type": "string"}},
        "actionable_recommendation": {"type": "string"},
    },
}

# =====================================================================
# 2. STRICT OFFLINE SYSTEM PROMPTS (GGUF / LOCAL LLM)
# =====================================================================

SYSTEM_PROMPT_EVALUATOR = """You are the offline LearnIQ Cognitive Diagnostic Engine.
Evaluate the student's answer against the expected programming logic.
You MUST output ONLY a valid JSON object matching this schema:
{
  "is_correct": boolean,
  "error_type": "none" | "syntax_error" | "off_by_one" | "scope_mismatch" | "return_vs_print" | "type_mismatch" | "index_out_of_bounds" | "uninitialized_variable" | "logic_inversion",
  "mistake_explanation": string (precise reason why this code fails, max 2 sentences),
  "underlying_misconception": string (e.g., "confusing 0-based with 1-based indexing"),
  "mastery_delta": float between -0.3 and 0.2,
  "suggest_reteaching": boolean (true if error indicates fundamental gap)
}
Do NOT include any preamble, conversational text, or markdown other than valid JSON."""

SYSTEM_PROMPT_RETEACHER = """You are Chami the Chameleon, the LearnIQ empathetic teaching twin.
A student failed an exercise due to a specific misconception.
Explain the topic using an easy, tangible physical analogy (e.g. backpacks, numbered pigeonholes, conveyor belts).
Output ONLY valid JSON matching this schema:
{
  "topic_id": string,
  "topic_title": string,
  "mistake_diagnosis": string,
  "easy_analogy": {
    "headline": string,
    "analogy_text": string,
    "visual_cue": string (e.g. "🎒 Slot 0 is the front pocket")
  },
  "step_by_step_breakdown": [string, string, string],
  "retest_exercise": {
    "exercise_id": string,
    "prompt": string,
    "code_snippet": string,
    "options": [string, string, string],
    "correct_option_index": int (0, 1, or 2),
    "explanation": string
  }
}
Output STRICT JSON ONLY."""

SYSTEM_PROMPT_DOUBT_ASSISTANT = """You are Chami, the LearnIQ coding assistant.
Answer the student's question based strictly on Python fundamentals and provided context documents.
Output ONLY valid JSON matching this schema:
{
  "question": string,
  "direct_answer": string (concise, crystal clear 2-3 sentences),
  "code_example": string (clean runnable Python snippet),
  "chami_tip": string (pro tip or edge case alert),
  "source_citations": [string],
  "search_mode": "offline_local_assets" | "online_web_search" | "hybrid"
}
Output STRICT JSON ONLY."""


# =====================================================================
# 3. ROBUST JSON EXTRACTION UTILITY
# =====================================================================

def extract_clean_json(raw_text: str) -> Optional[Dict[str, Any]]:
    """Extract and parse JSON from raw model output, handling code fences and stray tokens."""
    if not raw_text or not raw_text.strip():
        return None

    # Try direct parse first
    try:
        return json.loads(raw_text.strip())
    except json.JSONDecodeError:
        pass

    # Extract content inside markdown ```json ... ``` blocks
    match = re.search(r"```(?:json)?\s*(\{[\s\S]*?\})\s*```", raw_text)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass

    # Extract first curly brace pair { ... }
    first_brace = raw_text.find("{")
    last_brace = raw_text.rfind("}")
    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        candidate = raw_text[first_brace : last_brace + 1]
        try:
            return json.loads(candidate)
        except json.JSONDecodeError:
            pass

    return None
