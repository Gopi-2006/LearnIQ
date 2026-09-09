"""Verification test suite for LearnIQ Offline AI Engine & Learning Twin."""

import json
from document_parser import curriculum_parser
from learning_twin_engine import learning_twin_engine
from doubt_search_service import doubt_search_service


def test_offline_engine():
    print("==================================================")
    print("TEST 1: Document & Curriculum Parser")
    print("==================================================")
    nodes = curriculum_parser.load_cached_or_build()
    print(f"Loaded curriculum nodes count: {len(nodes)}")
    assert len(nodes) >= 6, "Expected at least 6 core curriculum nodes"
    assert "python.variables" in nodes
    assert "python.lists.indexing" in nodes
    assert "python.functions.return_vs_print" in nodes
    print("Sample node title:", nodes["python.lists.indexing"].title)
    print("Sample analogy:", nodes["python.lists.indexing"].analogy["headline"])
    print("Test 1 Passed!\n")

    print("==================================================")
    print("TEST 2: Lesson Execution First & Reading Gating")
    print("==================================================")
    tid = "python.lists.indexing"
    # Attempting practice before reading must be blocked!
    gated_res = learning_twin_engine.evaluate_submission(
        topic_id=tid,
        exercise_id="ex_index_01",
        student_answer="Option A",
        expected_answer="Option A",
    )
    print("Attempt before reading:", gated_res)
    assert gated_res.get("gating_alert") is True
    assert "Lesson Execution First" in gated_res["message"]

    # Now mark reading as completed
    unlock_res = learning_twin_engine.mark_reading_completed(tid)
    print("Mark reading completed:", unlock_res)
    assert unlock_res["status"] == "reading_unlocked_practice"
    assert learning_twin_engine.can_attempt_practice(tid) is True
    print("Test 2 Passed!\n")

    print("==================================================")
    print("TEST 3: Error-Driven Re-Teaching & Analogy")
    print("==================================================")
    # Simulate wrong answer on zero-based index
    fail_res = learning_twin_engine.evaluate_submission(
        topic_id=tid,
        exercise_id="ex_index_01",
        student_answer="3",
        expected_answer="0",
        code_context="nums = [10, 20, 30]; nums[3]",
    )
    print("Evaluation on error:", fail_res["error_type"])
    print("Mistake explanation:", fail_res["mistake_explanation"])
    assert fail_res["is_correct"] is False
    assert fail_res["re_teaching_required"] is True
    assert "reteaching_package" in fail_res
    print("Re-teaching easy analogy:", fail_res["reteaching_package"]["easy_analogy"]["headline"])
    print("Test 3 Passed!\n")

    print("==================================================")
    print("TEST 4: Mastery & Non-Repetition Lock")
    print("==================================================")
    # Consecutive correct answers to reach mastery >= 0.85
    learning_twin_engine.evaluate_submission(
        topic_id=tid, exercise_id="ex_index_01", student_answer="0", expected_answer="0"
    )
    learning_twin_engine.evaluate_submission(
        topic_id=tid, exercise_id="ex_index_01", student_answer="0", expected_answer="0"
    )
    win_res = learning_twin_engine.evaluate_submission(
        topic_id=tid, exercise_id="ex_index_01", student_answer="0", expected_answer="0"
    )
    print("Mastery score reached:", win_res["new_mastery"])
    print("Is topic mastered:", win_res["is_mastered"])
    assert tid in learning_twin_engine.profile.completed_topic_ids
    # Next node must not return this completed topic
    next_node = learning_twin_engine.get_next_progression_node()
    if next_node:
        print("Next progression node:", next_node["topic_id"])
        assert next_node["topic_id"] != tid
    print("Test 4 Passed!\n")

    print("==================================================")
    print("TEST 5: Stage Diagnostics & Weakness Alert")
    print("==================================================")
    diag = learning_twin_engine.get_stage_diagnostics()
    print("Stage title:", diag["stage_title"])
    print("Overall mastery:", diag["overall_mastery"])
    print("Actionable recommendation:", diag["actionable_recommendation"])
    assert "current_stage" in diag
    print("Test 5 Passed!\n")

    print("==================================================")
    print("TEST 6: Hybrid Doubt Search (Offline & Online)")
    print("==================================================")
    # Test offline doubt answering
    offline_ans = doubt_search_service.ask("Why does print return None in Python?", force_offline=True)
    print("Offline Question:", offline_ans["question"])
    print("Direct Answer:", offline_ans["direct_answer"][:150] + "...")
    print("Citation:", offline_ans["source_citations"])
    assert offline_ans["search_mode"] == "offline_local_assets"
    print("Test 6 Passed!\n")

    print("ALL 6 OFFLINE AI ENGINE TESTS PASSED!")


if __name__ == "__main__":
    test_offline_engine()
