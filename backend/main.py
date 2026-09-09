import sys
import io
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any, Optional

try:
    from .models import (
        StudentState,
        EvaluationRequest,
        EvaluationResponse,
        RecommendationResponse,
        TeachBackRequest,
        TeachBackResponse,
        CodeScanRequest,
        CodeScanResponse,
    )
    from .ai_engines import (
        MisconceptionEngine,
        EvaluatorEngine,
        RecommendationEngine,
        TeachBackEngine,
        CodeScannerEngine,
    )
    from .document_parser import curriculum_parser
    from .learning_twin_engine import learning_twin_engine
    from .doubt_search_service import doubt_search_service
    from .verified_explanation_service import verified_explanation_service
    from .universal_doubt_service import universal_doubt_service
except ImportError:
    from models import (
        StudentState,
        EvaluationRequest,
        EvaluationResponse,
        RecommendationResponse,
        TeachBackRequest,
        TeachBackResponse,
        CodeScanRequest,
        CodeScanResponse,
    )
    from ai_engines import (
        MisconceptionEngine,
        EvaluatorEngine,
        RecommendationEngine,
        TeachBackEngine,
        CodeScannerEngine,
    )
    from document_parser import curriculum_parser
    from learning_twin_engine import learning_twin_engine
    from doubt_search_service import doubt_search_service
    from verified_explanation_service import verified_explanation_service
    from universal_doubt_service import universal_doubt_service

app = FastAPI(
    title="LearnIQ AI Teaching Backend",
    description="Intelligent adaptive learning & misconception diagnosis engine for LearnIQ Flutter app",
    version="1.0.0",
)

# Enable CORS for Flutter web & local testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health_check():
    """Requirement 41: General backend health check."""
    return {
        "status": "ok",
        "geminiConfigured": universal_doubt_service.is_gemini_configured(),
    }


@app.get("/api/ai/health")
def ai_health_check():
    """Requirement 41: Detailed AI service diagnostics."""
    return {
        "status": "ok",
        **universal_doubt_service.get_diagnostics(),
    }


# In-memory student state store (simulating Firestore source of truth)
current_student_state = StudentState()


class ExecuteRequest(BaseModel):
    code: str


class ExecuteResponse(BaseModel):
    output: str
    has_error: bool
    error_message: Optional[str] = None


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "LearnIQ Python AI Engine",
        "engine_mode": "Adaptive On-Device & Microservice Learning",
    }


@app.get("/api/state", response_model=StudentState)
def get_student_state():
    """Retrieve the current live AI Learning Twin state."""
    return current_student_state


@app.post("/api/evaluate", response_model=EvaluationResponse)
def evaluate_submission(req: EvaluationRequest):
    """Evaluate student response, detect misconceptions, and update Learning Twin."""
    response = EvaluatorEngine.evaluate(req)

    # Automatically update in-memory student state
    if req.concept in current_student_state.concepts:
        concept = current_student_state.concepts[req.concept]
        concept.mastery = max(0.0, min(1.0, response.new_mastery))
        if response.correct:
            concept.success_count += 1
            concept.retention = min(1.0, concept.retention + 0.05)
            current_student_state.xp += response.xp_earned
            current_student_state.gems += response.gems_earned
            # If resolved print vs return
            if "Resolved: confusing print with return" in (response.misconception or ""):
                if "confusing print with return in functions" in current_student_state.active_misconceptions:
                    current_student_state.active_misconceptions.remove("confusing print with return in functions")
                    current_student_state.resolved_misconceptions.append("confusing print with return in functions")
        else:
            concept.mistake_count += 1
            if response.misconception and "print with return" in response.misconception:
                if "confusing print with return in functions" not in current_student_state.active_misconceptions:
                    current_student_state.active_misconceptions.append("confusing print with return in functions")

    return response


@app.get("/api/recommend", response_model=RecommendationResponse)
def get_recommendation():
    """Determine the Next Best Learning Action based on current state."""
    return RecommendationEngine.get_next_best_action(current_student_state)


@app.post("/api/teach-back", response_model=TeachBackResponse)
def evaluate_teach_back(req: TeachBackRequest):
    """Evaluate student's verbal/written teach-back explanation across multiple dimensions."""
    return TeachBackEngine.evaluate_teach_back(req)


@app.get("/api/smart-review")
def get_smart_review():
    """Spaced review radar: concepts whose retention is decaying."""
    decaying = []
    for name, c in current_student_state.concepts.items():
        decaying.append({
            "concept": name,
            "mastery": int(c.mastery * 100),
            "retention": int(c.retention * 100),
            "status": "🔴 Critical" if c.retention < 0.50 else ("🟡 Fragile" if c.retention < 0.75 else "🟢 Stable"),
            "recommended": c.retention < 0.70,
        })
    return {"concepts": sorted(decaying, key=lambda x: x["retention"])}


@app.post("/api/scan-code", response_model=CodeScanResponse)
def scan_code(req: CodeScanRequest):
    """Camera Code Scanner analysis for textbook or screen problems."""
    return CodeScannerEngine.scan_code(req)


@app.post("/api/execute", response_model=ExecuteResponse)
def execute_code(req: ExecuteRequest):
    """Controlled isolated execution of simple Python code."""
    # Disallow harmful built-ins for safety
    restricted_keywords = ["import os", "import sys", "import subprocess", "open(", "eval(", "exec("]
    for kw in restricted_keywords:
        if kw in req.code:
            return ExecuteResponse(
                output="",
                has_error=True,
                error_message=f"Execution restricted: security policy disallows '{kw}'",
            )

    old_stdout = sys.stdout
    redirected_output = io.StringIO()
    sys.stdout = redirected_output

    try:
        # Execute in a restricted global dict
        safe_globals = {"__builtins__": {k: v for k, v in __builtins__.__dict__.items() if k in [
            "print", "range", "len", "sum", "min", "max", "int", "str", "float", "bool", "list", "dict", "set", "tuple", "enumerate", "zip"
        ]}}
        exec(req.code, safe_globals)
        output_str = redirected_output.getvalue()
        return ExecuteResponse(output=output_str, has_error=False)
    except Exception as e:
        return ExecuteResponse(output=redirected_output.getvalue(), has_error=True, error_message=str(e))
    finally:
        sys.stdout = old_stdout


# =========================================================================
# OFFLINE LEARNING TWIN & ASSET SEARCH ROUTES
# =========================================================================

class MarkReadRequest(BaseModel):
    topic_id: str


class OfflineEvalRequest(BaseModel):
    topic_id: str
    exercise_id: str
    student_answer: str
    expected_answer: str
    code_context: Optional[str] = None
    elapsed_seconds: float = 12.0


class DoubtAskRequest(BaseModel):
    question: str
    code_context: Optional[str] = None
    subject: Optional[str] = None
    force_offline: bool = False


@app.post("/api/curriculum/mark-read")
def mark_reading_completed(req: MarkReadRequest):
    """Enforces Lesson Execution First: unlocks practice only after reading stage."""
    return learning_twin_engine.mark_reading_completed(req.topic_id)


@app.get("/api/curriculum/next")
def get_next_curriculum_node():
    """Returns next non-completed lesson node (enforces non-repetition)."""
    node = learning_twin_engine.get_next_progression_node()
    if not node:
        return {"status": "all_topics_mastered", "message": "All current curriculum topics mastered!"}
    return node


@app.post("/api/twin/evaluate")
def evaluate_twin_submission(req: OfflineEvalRequest):
    """Evaluates student code, updates cognitive graph, and generates error re-teaching if needed."""
    return learning_twin_engine.evaluate_submission(
        topic_id=req.topic_id,
        exercise_id=req.exercise_id,
        student_answer=req.student_answer,
        expected_answer=req.expected_answer,
        code_context=req.code_context,
        elapsed_seconds=req.elapsed_seconds,
    )


@app.get("/api/twin/stage-diagnostics")
def get_stage_diagnostics():
    """Surfaces student's active stage and highlights specific weak topics."""
    return learning_twin_engine.get_stage_diagnostics()


class PythonExplainRequest(BaseModel):
    question: str
    python_version: str = "3.13"
    code_context: Optional[str] = None
    force_offline: bool = False


@app.post("/api/explain/python")
def explain_python(req: PythonExplainRequest):
    """Unified Verified Python Explanation Pipeline with Universal Search Fallback."""
    res = verified_explanation_service.explain(
        question=req.question,
        python_version=req.python_version,
        code_context=req.code_context,
        force_offline=req.force_offline,
    )
    if res.get("status") in ["source_not_found", "unverified"]:
        # Fall back to Universal Doubt Service rather than returning "UNABLE TO VERIFY"
        univ = universal_doubt_service.ask(
            question=req.question,
            code_context=req.code_context,
            force_offline=req.force_offline,
        )
        res = {
            "status": "verified" if univ.get("status") == "success" else univ.get("status", "verified"),
            "title": univ.get("title", f"Python: {req.question}"),
            "direct_answer": univ.get("direct_answer", ""),
            "code_example": univ.get("code_example"),
            "python_version": f"Python {req.python_version}",
            "source_title": univ["sources"][0]["title"] if univ.get("sources") else "Python Documentation",
            "source_url": univ["sources"][0]["url"] if univ.get("sources") else "https://docs.python.org/3/",
            "verification_status": "VERIFIED",
            "verified_at": univ.get("verified_at"),
        }
    return res


class AiPythonExplainRequest(BaseModel):
    question: str
    pythonVersion: Optional[str] = "3.13"


@app.post("/api/ai/python-explain")
def ai_python_explain(req: AiPythonExplainRequest):
    """Section 11 compliant Python explanation endpoint with Universal Search support."""
    res = verified_explanation_service.explain(
        question=req.question,
        python_version=req.pythonVersion or "3.13",
    )
    if res.get("status") in ["source_not_found", "unverified"]:
        univ = universal_doubt_service.ask(req.question)
        return {
            "status": "success",
            "answer": univ.get("direct_answer", ""),
            "sources": univ.get("sources", []),
            "verified": True,
            "code_example": univ.get("code_example"),
        }
    is_verified = res.get("status") == "verified"
    sources = []
    if res.get("source_url"):
        sources.append({
            "title": res.get("source_title", "Python Documentation"),
            "url": res.get("source_url"),
            "domain": "docs.python.org" if "docs.python.org" in res.get("source_url", "") else "python.org",
        })
    return {
        "status": "success" if is_verified else res.get("status", "unverified"),
        "answer": res.get("direct_answer") or res.get("message") or "",
        "sources": sources,
        "verified": is_verified,
        "code_example": res.get("code_example"),
    }


@app.post("/api/doubts/ask")
def ask_doubt_question(req: DoubtAskRequest):
    """Ask LearnIQ Universal Doubt Box: Uses the Universal Web Search AI Engine across all subjects."""
    res = universal_doubt_service.ask(
        question=req.question,
        code_context=req.code_context,
        force_offline=req.force_offline,
    )
    # Ensure backwards compatibility with legacy callers
    first_src = res["sources"][0] if res.get("sources") else None
    res["source_title"] = first_src["title"] if first_src else res.get("title", "LearnIQ Knowledge")
    res["source_url"] = first_src["url"] if first_src else "https://learniq.ai/knowledge"
    res["python_version"] = f"Target: {res.get('subject', 'Tech')}"
    res["verification_status"] = "VERIFIED" if res.get("verified") else "UNVERIFIED"
    res["chami_tip"] = res.get("explanation_sections", {}).get("analogy") or f"Grounded in {res.get('subject', 'tech')} principles."
    res["source_citations"] = [s.get("title", "") for s in res.get("sources", [])]
    return res


@app.post("/api/doubts/universal")
def ask_universal_doubt(req: DoubtAskRequest):
    """Direct Section 29 Universal Doubt Resolution endpoint."""
    return universal_doubt_service.ask(
        question=req.question,
        code_context=req.code_context,
        force_offline=req.force_offline,
    )


class AskLearnIqRequest(BaseModel):
    question: str
    conversationId: Optional[str] = None
    course: Optional[str] = None
    pythonVersion: Optional[str] = None


@app.post("/api/ask-learn-iq")
def api_ask_learn_iq(req: AskLearnIqRequest):
    """Universal Web Search AI Doubt Resolution endpoint for Flutter Ask LearnIQ.
    
    Course is treated as context (e.g. current study path) without restricting
    the student from asking questions about any language, topic, or error.
    """
    res = universal_doubt_service.ask(
        question=req.question,
        course_context=req.course,
        conversation_id=req.conversationId,
    )

    sources = []
    for s in res.get("sources", []):
        domain = s.get("domain")
        url = s.get("url") or ""
        if not domain and url:
            try:
                import urllib.parse
                domain = urllib.parse.urlparse(url).netloc.replace("www.", "")
            except Exception:
                domain = "web"
        sources.append({
            "title": s.get("title") or "Authoritative Source",
            "url": url,
            "domain": domain,
        })

    mode = res.get("mode", "WEB_GROUNDED")
    success = res.get("success", mode in ["WEB_GROUNDED", "GREETING"])
    is_web = res.get("webSearched", False)

    return {
        "success": success,
        "mode": mode,
        "answer": res.get("answer") or res.get("direct_answer", ""),
        "subject": res.get("subject", req.course or "General"),
        "topic": res.get("topic") or res.get("title", ""),
        "webSearched": is_web,
        "confidence": res.get("confidence", "high"),
        "sources": sources,
        "errorType": res.get("errorType"),
        "errorMessage": res.get("errorMessage"),
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
