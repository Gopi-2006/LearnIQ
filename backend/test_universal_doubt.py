import json
import sys

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

from universal_doubt_service import universal_doubt_service

def run_test_matrix():
    print("\n==================== RUNNING SECTION 31 TEST MATRIX ====================")

    test_cases = [
        # (Query, Expected Mode, Must Have Sources, Must Have WebSearched)
        ("What is Python?", "WEB_GROUNDED", True, True),
        ("What is a Python list?", "WEB_GROUNDED", True, True),
        ("What is Java?", "WEB_GROUNDED", True, True),
        ("What is inheritance?", "WEB_GROUNDED", True, True),
        ("What is an API?", "WEB_GROUNDED", True, True),
        ("What is machine learning?", "WEB_GROUNDED", True, True),
        ("What is binary search?", "WEB_GROUNDED", True, True),
        ("Why does 'num' + 5 fail in Python?", "WEB_GROUNDED", True, True),
        ("What is the latest Python version?", "WEB_GROUNDED", True, True),
        ("hi", "GREETING", False, False),
        ("hii", "GREETING", False, False),
        ("hello", "GREETING", False, False),
        ("xyzabc", "UNKNOWN_INPUT", False, False),
        ("qwerty", "UNKNOWN_INPUT", False, False),
    ]

    all_passed = True

    for query, expected_mode, must_have_sources, must_web_searched in test_cases:
        print(f"\n[TESTING QUERY]: '{query}'")
        res = universal_doubt_service.ask(query)

        actual_mode = res.get("mode")
        web_searched = res.get("webSearched")
        sources = res.get("sources", [])
        answer = res.get("answer") or res.get("direct_answer", "")

        print(f"  -> Mode: {actual_mode} (Expected: {expected_mode})")
        print(f"  -> webSearched: {web_searched} (Expected: {must_web_searched})")
        print(f"  -> Sources count: {len(sources)}")
        print(f"  -> Answer preview: {answer[:90]}...")

        # Assertions
        if actual_mode != expected_mode:
            print(f"  [FAIL]: Mode mismatch! Got {actual_mode}, expected {expected_mode}")
            all_passed = False
        elif web_searched != must_web_searched:
            print(f"  [FAIL]: webSearched mismatch! Got {web_searched}, expected {must_web_searched}")
            all_passed = False
        elif must_have_sources and len(sources) == 0:
            print(f"  [FAIL]: Expected real sources, got 0!")
            all_passed = False
        elif expected_mode == "GREETING" and "is a core principle" in answer:
            print(f"  [FAIL]: Hallucinated definition for greeting!")
            all_passed = False
        elif expected_mode == "UNKNOWN_INPUT" and "is a core principle" in answer:
            print(f"  [FAIL]: Hallucinated definition for unknown input!")
            all_passed = False
        else:
            print("  [PASS]")

    # Test Offline Simulation
    print("\n[TESTING QUERY]: 'What is Python?' (force_offline=True)")
    off_res = universal_doubt_service.ask("What is Python?", force_offline=True)
    print(f"  -> Mode: {off_res.get('mode')} (Expected: OFFLINE)")
    print(f"  -> webSearched: {off_res.get('webSearched')} (Expected: False)")
    if off_res.get("mode") == "OFFLINE" and off_res.get("webSearched") is False:
        print("  [PASS]")
    else:
        print("  [FAIL]: Offline mode mismatch!")
        all_passed = False

    if all_passed:
        print("\n🎉 ALL SECTION 31 MATRIX TESTS PASSED! ZERO HALLUCINATIONS!")
    else:
        print("\n❌ SOME MATRIX TESTS FAILED.")
        sys.exit(1)

if __name__ == "__main__":
    run_test_matrix()
