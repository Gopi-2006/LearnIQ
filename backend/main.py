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
        "npu_mode": "iQOO Monster AI Hybrid Engine Active",
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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
