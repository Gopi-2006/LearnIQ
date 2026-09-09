"""Test Verified Python Explanation & Internet-First AI Service."""

from verified_explanation_service import verified_explanation_service

def run_tests():
    print("==================================================")
    print("TEST 1: Online Verified Query (List)")
    print("==================================================")
    res_list = verified_explanation_service.explain("What is a Python list?", force_offline=False)
    print("Status:", res_list.get("status"))
    print("Title:", res_list.get("source_title"))
    print("URL:", res_list.get("source_url"))
    print("Version:", res_list.get("python_version"))
    print("Answer:", res_list.get("direct_answer")[:80] + "...")
    assert res_list["status"] == "verified"
    assert "docs.python.org" in res_list["source_url"]
    assert res_list["verification_status"] == "VERIFIED"
    print("Test 1 Passed!\n")

    print("==================================================")
    print("TEST 2: Online Verified Query (range(5))")
    print("==================================================")
    res_range = verified_explanation_service.explain("What does range(5) do?", force_offline=False)
    print("Status:", res_range.get("status"))
    print("Title:", res_range.get("source_title"))
    print("URL:", res_range.get("source_url"))
    print("Answer:", res_range.get("direct_answer")[:80] + "...")
    assert res_range["status"] == "verified"
    assert "docs.python.org" in res_range["source_url"]
    print("Test 2 Passed!\n")

    print("==================================================")
    print("TEST 3: Offline Gating (Internet Unavailable)")
    print("==================================================")
    res_offline = verified_explanation_service.explain("What is a Python generator?", force_offline=True)
    print("Status:", res_offline.get("status"))
    print("Message:\n", res_offline.get("message"))
    assert res_offline["status"] == "offline"
    assert res_offline["verification_status"] == "UNVERIFIED"
    assert "NO INTERNET CONNECTION" in res_offline["message"] or "internet connection" in res_offline["message"]
    print("Test 3 Passed!\n")

    print("==================================================")
    print("TEST 4: Code & Syntax Validation")
    print("==================================================")
    valid_code = "nums = [1, 2, 3]\nprint(sum(nums))"
    res_valid = verified_explanation_service._validate_python_code(valid_code)
    print("Valid Code result:", res_valid)
    assert res_valid["valid"] is True
    assert res_valid["output"] == "6"

    invalid_code = "for x in range(5\n    print(x)"
    res_invalid = verified_explanation_service._validate_python_code(invalid_code)
    print("Invalid Code result:", res_invalid)
    assert res_invalid["valid"] is False
    assert res_invalid["error_type"] == "SyntaxError"
    print("Test 4 Passed!\n")

    print("==================================================")
    print("TEST 5: Caching Check")
    print("==================================================")
    res_cached = verified_explanation_service.explain("What is a Python list?", force_offline=False)
    assert res_cached.get("from_cache") is True
    print("Retrieved from cache:", res_cached.get("from_cache"))
    print("Test 5 Passed!\n")

    print("ALL 5 VERIFIED EXPLAINER TESTS PASSED!")

if __name__ == "__main__":
    run_tests()
