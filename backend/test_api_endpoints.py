import sys
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_endpoints():
    print("Testing /api/doubts/ask with 'What is Java?'...")
    resp = client.post("/api/doubts/ask", json={"question": "What is Java?"})
    assert resp.status_code == 200, f"Expected 200, got {resp.status_code}"
    data = resp.json()
    print("Subject:", data.get("subject"))
    print("Title:", data.get("title"))
    print("Direct Answer snippet:", data.get("direct_answer")[:80])
    print("Sources:", len(data.get("sources", [])))
    assert "UNABLE TO VERIFY" not in data.get("title", "").upper()
    assert data.get("verified") is True
    print("[PASS] /api/doubts/ask Java")

    print("\nTesting /api/doubts/universal with 'What is an API?'...")
    resp = client.post("/api/doubts/universal", json={"question": "What is an API?"})
    assert resp.status_code == 200
    data = resp.json()
    print("Subject:", data.get("subject"))
    print("Sources:", len(data.get("sources", [])))
    print("[PASS] /api/doubts/universal API")

    print("\nTesting /api/explain/python fallback with 'What is Python list comprehension?'...")
    resp = client.post("/api/explain/python", json={"question": "What is Python list comprehension?"})
    assert resp.status_code == 200
    data = resp.json()
    print("Title:", data.get("title"))
    assert "UNABLE TO VERIFY" not in data.get("title", "").upper()
    print("[PASS] /api/explain/python list comprehension fallback")

    print("\nALL FASTAPI ENDPOINT TESTS PASSED!")

if __name__ == "__main__":
    test_endpoints()
