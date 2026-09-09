@echo off
echo Starting LearnIQ Python AI Backend (FastAPI)...
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
pause
