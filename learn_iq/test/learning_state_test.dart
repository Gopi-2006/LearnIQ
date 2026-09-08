import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_iq/core/models/learning_models.dart';
import 'package:learn_iq/core/services/learning_state_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('LearnIQ Student Progression & Evidence Gating Tests', () {
    test('TEST 1 — Fresh Install Starts Completely from Zero', () {
      final student = StudentState.newLearner(name: 'Gopi');

      expect(student.xp, 0);
      expect(student.streak, 0);
      expect(student.gems, 0);
      expect(student.level, 1);
      expect(student.hearts, 5);
      expect(student.energy, 100);
      expect(student.dailyProgressMinutes, 0);
      expect(student.isNewLearner, isTrue);
      expect(student.hasLearningEvidence, isFalse);
      expect(student.concepts.isEmpty, isTrue);
      expect(student.weakTopics.isEmpty, isTrue);
      expect(student.masteredTopics.isEmpty, isTrue);
      expect(student.activeMisconceptions.isEmpty, isTrue);
      expect(student.completedLessonIds.isEmpty, isTrue);
    });

    test('TEST 2 — Weakness Is Never Declared Without Evidence', () {
      // 0 attempts -> notStarted, not weak
      final unattemptedConcept = ConceptMastery(
        mastery: 0.0,
        retention: 0.0,
        confidence: 0.0,
        mistakeCount: 0,
        successCount: 0,
      );
      expect(unattemptedConcept.totalAttempts, 0);
      expect(unattemptedConcept.hasEnoughEvidence, isFalse);
      expect(unattemptedConcept.status, TopicStatus.notStarted);
      expect(unattemptedConcept.status != TopicStatus.weak, isTrue);

      // Single wrong answer -> not immediately weak (Rule #2 & #14)
      final singleMistake = ConceptMastery(
        mastery: 0.45,
        retention: 0.40,
        confidence: 0.35,
        mistakeCount: 1,
        successCount: 0,
      );
      expect(singleMistake.totalAttempts, 1);
      expect(singleMistake.hasEnoughEvidence, isFalse);
      expect(singleMistake.status, TopicStatus.learning);

      // Repeated mistakes with confirmed evidence -> weak
      final repeatedMistakes = ConceptMastery(
        mastery: 0.40,
        retention: 0.35,
        confidence: 0.30,
        mistakeCount: 3,
        successCount: 1,
      );
      expect(repeatedMistakes.totalAttempts, 4);
      expect(repeatedMistakes.hasEnoughEvidence, isTrue);
      expect(repeatedMistakes.status, TopicStatus.weak);
    });

    test('TEST 3 — Mastery Requires Confirmed Successes and High Accuracy', () {
      final highMastery = ConceptMastery(
        mastery: 0.90,
        retention: 0.88,
        confidence: 0.92,
        mistakeCount: 0,
        successCount: 3,
      );
      expect(highMastery.status, TopicStatus.mastered);
    });

    test('TEST 4 — LearningStateManager Current Lesson Derivation for New Student', () {
      final manager = LearningStateManager();
      // Uncompleted lessons start at lesson 1 (unit_01_meet_python)
      expect(manager.student.isNewLearner, isTrue);
      expect(manager.currentLesson.id, 'unit_01_meet_python');
      expect(manager.currentLesson.title, contains('Meet Python'));
      expect(manager.currentLessonIndex, 1);
      expect(manager.courseProgressPercent, 0.0);
    });
  });
}
