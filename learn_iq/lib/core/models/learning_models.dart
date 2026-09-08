import 'package:flutter/material.dart';

enum LoadState {
  idle,
  loading,
  success,
  error,
  timeout,
}

class SyncEvent {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final int timestamp;
  final bool isSynced;

  SyncEvent({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'payload': payload,
    'timestamp': timestamp,
    'is_synced': isSynced,
  };

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
    id: json['id'] as String,
    type: json['type'] as String,
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    timestamp: json['timestamp'] as int,
    isSynced: json['is_synced'] as bool? ?? false,
  );
}

enum TopicStatus {
  notStarted,
  learning,
  practicing,
  mastered,
  weak,
}

class ConceptMastery {
  final double mastery;
  final double retention;
  final double confidence;
  final int mistakeCount;
  final int successCount;

  ConceptMastery({
    required this.mastery,
    required this.retention,
    required this.confidence,
    this.mistakeCount = 0,
    this.successCount = 0,
  });

  int get totalAttempts => mistakeCount + successCount;
  bool get hasEnoughEvidence => totalAttempts >= 2;
  double get consistency => (retention + confidence) / 2.0;

  TopicStatus get status {
    if (totalAttempts == 0) return TopicStatus.notStarted;
    if (mastery >= 0.85 && successCount >= 2) return TopicStatus.mastered;
    if (hasEnoughEvidence && (mastery < 0.50 || (mistakeCount > successCount && mistakeCount >= 2))) {
      return TopicStatus.weak;
    }
    if (totalAttempts >= 4) return TopicStatus.practicing;
    return TopicStatus.learning;
  }

  ConceptMastery copyWith({
    double? mastery,
    double? retention,
    double? confidence,
    int? mistakeCount,
    int? successCount,
  }) {
    return ConceptMastery(
      mastery: mastery ?? this.mastery,
      retention: retention ?? this.retention,
      confidence: confidence ?? this.confidence,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      successCount: successCount ?? this.successCount,
    );
  }

  factory ConceptMastery.fromJson(Map<String, dynamic> json) {
    return ConceptMastery(
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.5,
      retention: (json['retention'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      mistakeCount: json['mistake_count'] as int? ?? 0,
      successCount: json['success_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'mastery': mastery,
    'retention': retention,
    'confidence': confidence,
    'mistake_count': mistakeCount,
    'success_count': successCount,
  };
}

class StudentState {
  final String userId;
  final String name;
  final String language;
  final int level;
  final String levelTitle;
  final int xp;
  final int streak;
  final int energy;
  final int maxEnergy;
  final int hearts;
  final int maxHearts;
  final int gems;
  final int dailyGoalMinutes;
  final int dailyProgressMinutes;
  final String experienceLevel;
  final Map<String, ConceptMastery> concepts;
  final List<String> activeMisconceptions;
  final List<String> resolvedMisconceptions;
  final List<String> completedLessonIds;

  StudentState({
    required this.userId,
    required this.name,
    required this.language,
    required this.level,
    required this.levelTitle,
    required this.xp,
    required this.streak,
    required this.energy,
    required this.maxEnergy,
    this.hearts = 5,
    this.maxHearts = 5,
    required this.gems,
    required this.dailyGoalMinutes,
    required this.dailyProgressMinutes,
    this.experienceLevel = "beginner",
    required this.concepts,
    required this.activeMisconceptions,
    required this.resolvedMisconceptions,
    this.completedLessonIds = const [],
  });

  StudentState copyWith({
    String? name,
    String? language,
    int? xp,
    int? streak,
    int? energy,
    int? hearts,
    int? gems,
    int? level,
    String? levelTitle,
    int? dailyGoalMinutes,
    int? dailyProgressMinutes,
    String? experienceLevel,
    Map<String, ConceptMastery>? concepts,
    List<String>? activeMisconceptions,
    List<String>? resolvedMisconceptions,
    List<String>? completedLessonIds,
  }) {
    return StudentState(
      userId: userId,
      name: name ?? this.name,
      language: language ?? this.language,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy,
      hearts: hearts ?? this.hearts,
      maxHearts: maxHearts,
      gems: gems ?? this.gems,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyProgressMinutes: dailyProgressMinutes ?? this.dailyProgressMinutes,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      concepts: concepts ?? this.concepts,
      activeMisconceptions: activeMisconceptions ?? this.activeMisconceptions,
      resolvedMisconceptions: resolvedMisconceptions ?? this.resolvedMisconceptions,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  bool get isNewLearner => completedLessonIds.isEmpty && xp == 0;
  bool get hasLearningEvidence => concepts.values.any((c) => c.totalAttempts > 0) || completedLessonIds.isNotEmpty;
  List<MapEntry<String, ConceptMastery>> get weakTopics => concepts.entries.where((e) => e.value.status == TopicStatus.weak).toList();
  List<MapEntry<String, ConceptMastery>> get masteredTopics => concepts.entries.where((e) => e.value.status == TopicStatus.mastered).toList();

  factory StudentState.newLearner({
    String name = "Alex",
    String language = "python",
    int dailyGoal = 10,
    String experience = "beginner",
  }) {
    return StudentState(
      userId: "user_new_01",
      name: name,
      language: language,
      level: 1,
      levelTitle: "Code Newbie",
      xp: 0,
      streak: 0,
      energy: 100,
      maxEnergy: 100,
      hearts: 5,
      maxHearts: 5,
      gems: 0,
      dailyGoalMinutes: dailyGoal,
      dailyProgressMinutes: 0,
      experienceLevel: experience,
      concepts: {},
      activeMisconceptions: [],
      resolvedMisconceptions: [],
      completedLessonIds: [],
    );
  }

  factory StudentState.initial() {
    return StudentState.newLearner();
  }

  factory StudentState.demoReturningUser() {
    return StudentState(
      userId: "user_gopi_01",
      name: "Gopi",
      language: "python",
      level: 3,
      levelTitle: "Syntax Scout",
      xp: 1090,
      streak: 7,
      energy: 80,
      maxEnergy: 100,
      hearts: 5,
      maxHearts: 5,
      gems: 240,
      dailyGoalMinutes: 10,
      dailyProgressMinutes: 8,
      experienceLevel: "intermediate",
      concepts: {
        "variables": ConceptMastery(mastery: 0.92, retention: 0.91, confidence: 0.95, mistakeCount: 1, successCount: 14),
        "conditions": ConceptMastery(mastery: 0.81, retention: 0.74, confidence: 0.82, mistakeCount: 3, successCount: 11),
        "loops": ConceptMastery(mastery: 0.43, retention: 0.42, confidence: 0.48, mistakeCount: 7, successCount: 5),
        "functions": ConceptMastery(mastery: 0.58, retention: 0.61, confidence: 0.60, mistakeCount: 5, successCount: 8),
        "lists": ConceptMastery(mastery: 0.48, retention: 0.52, confidence: 0.50, mistakeCount: 6, successCount: 4),
      },
      activeMisconceptions: [
        "confusing print with return in functions",
        "zero-based index out-of-range in lists",
      ],
      resolvedMisconceptions: [
        "variable re-assignment confusion",
      ],
      completedLessonIds: [
        'unit_01_meet_python',
        'unit_02_variables',
        'unit_03_data_types',
        'unit_04_operators',
        'unit_05_decisions',
        'unit_06_loops',
        'node_vars',
        'node_types',
        'node_operators',
        'node_conditions',
        'node_loops',
      ],
    );
  }
}

enum ExerciseType {
  multipleChoice,
  outputPrediction,
  fillBlank,
  codeOrdering,
  bugFix,
  miniCoding,
  teachBack,
}

class Exercise {
  final String id;
  final String concept;
  final ExerciseType type;
  final String questionPrompt;
  final String? codeSnippet;
  final List<String>? options;
  final String? correctOption;
  final String? expectedAnswer;
  final String? explanation;
  final List<String>? orderBlocks;
  final List<String>? correctOrder;

  Exercise({
    required this.id,
    required this.concept,
    required this.type,
    required this.questionPrompt,
    this.codeSnippet,
    this.options,
    this.correctOption,
    this.expectedAnswer,
    this.explanation,
    this.orderBlocks,
    this.correctOrder,
  });
}

enum NodeStatus {
  completed,
  current,
  locked,
}

class CourseNode {
  final String id;
  final String title;
  final String unitTitle;
  final IconData icon;
  final NodeStatus status;
  final double masteryPercent;
  final int stars;
  final int weekNumber;
  final String weekTitle;
  final int dayNumber;

  CourseNode({
    required this.id,
    required this.title,
    required this.unitTitle,
    required this.icon,
    required this.status,
    required this.masteryPercent,
    required this.stars,
    this.weekNumber = 1,
    this.weekTitle = 'Week 1: Python Origin Mission',
    this.dayNumber = 1,
  });
}

class LeagueUser {
  final int rank;
  final String name;
  final int xp;
  final Color avatarColor;
  final bool isCurrentUser;

  LeagueUser({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatarColor,
    this.isCurrentUser = false,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int progress;
  final int total;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    required this.total,
  });
}

class DebugProblem {
  final String id;
  final String title;
  final String brokenCode;
  final String errorType;
  final String hint;
  final String expectedFix;
  final int xpReward;

  DebugProblem({
    required this.id,
    required this.title,
    required this.brokenCode,
    required this.errorType,
    required this.hint,
    required this.expectedFix,
    required this.xpReward,
  });
}

class CurriculumItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> keywords;

  CurriculumItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.keywords,
  });
}
