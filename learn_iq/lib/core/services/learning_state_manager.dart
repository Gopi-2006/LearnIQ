import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_models.dart';
import '../models/story_curriculum_models.dart';
import '../data/python_curriculum_data.dart';
import '../repositories/learning_repository.dart';
import '../utils/app_logger.dart';
import 'api_service.dart';

class LearningStateManager extends ChangeNotifier {
  // Singleton pattern to ensure single unified state instance across all routes
  static final LearningStateManager _instance = LearningStateManager._internal();
  factory LearningStateManager() => _instance;

  final LearningRepository _repository = LearningRepository();
  LearningRepository get repository => _repository;

  StudentState _student = StudentState.newLearner();
  StudentState get student => _student;

  LoadState _loadState = LoadState.idle;
  LoadState get loadState => _loadState;

  bool _isOnboardingComplete = false;
  bool get isOnboardingComplete => _isOnboardingComplete;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Map<String, dynamic>? _recommendation;
  Map<String, dynamic>? get recommendation => _recommendation;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Course tree nodes
  late List<CourseNode> _courseNodes;
  List<CourseNode> get courseNodes => _courseNodes;

  // Weekly league rankings
  late List<LeagueUser> _leagueUsers;
  List<LeagueUser> get leagueUsers => _leagueUsers;

  // Achievements
  late List<Achievement> _achievements;
  List<Achievement> get achievements => _achievements;

  // Debug Arena problems
  late List<DebugProblem> _debugProblems;
  List<DebugProblem> get debugProblems => _debugProblems;

  LearningStateManager._internal() {
    _initDefaultData();
    _recommendation = _computeLocalRecommendation();
    initSession();
  }

  Future<void> initSession() async {
    _loadState = LoadState.loading;
    AppLogger.auth('Loading local learner session from SharedPreferences...');
    try {
      final prefs = await SharedPreferences.getInstance();
      await _repository.loadPersistedQueue();
      _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      if (_isOnboardingComplete) {
        final savedName = prefs.getString('user_name') ?? 'Alex';
        final savedXp = prefs.getInt('user_xp') ?? 0;
        final savedStreak = prefs.getInt('user_streak') ?? 0;
        final savedLevel = prefs.getInt('user_level') ?? 1;
        final savedDailyProgress = prefs.getInt('user_daily_progress') ?? 0;
        final savedCompletedLessons = prefs.getStringList('user_completed_lessons') ?? <String>[];
        final savedActiveMisconceptions = prefs.getStringList('user_active_misconceptions') ?? <String>[];
        final savedResolvedMisconceptions = prefs.getStringList('user_resolved_misconceptions') ?? <String>[];

        Map<String, ConceptMastery> restoredConcepts = {};
        final savedConceptsRaw = prefs.getString('user_concepts_json');
        if (savedConceptsRaw != null && savedConceptsRaw.isNotEmpty) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(savedConceptsRaw);
            decoded.forEach((key, val) {
              if (val is Map<String, dynamic>) {
                restoredConcepts[key] = ConceptMastery.fromJson(val);
              }
            });
          } catch (e) {
            AppLogger.auth('Error decoding concepts json: $e');
          }
        }

        _student = StudentState.newLearner(name: savedName).copyWith(
          xp: savedXp,
          streak: savedStreak,
          level: savedLevel,
          dailyProgressMinutes: savedDailyProgress,
          completedLessonIds: savedCompletedLessons,
          concepts: restoredConcepts,
          activeMisconceptions: savedActiveMisconceptions,
          resolvedMisconceptions: savedResolvedMisconceptions,
        );
        _setupCourseNodesFromCurriculum();
      } else {
        _student = StudentState.newLearner();
        _setupNewLearnerCourseNodes();
      }
      _loadState = LoadState.success;
    } catch (e) {
      AppLogger.auth('Local storage read exception (defaulting cleanly): $e');
      _isOnboardingComplete = false;
      _student = StudentState.newLearner();
      _setupNewLearnerCourseNodes();
      _loadState = LoadState.error;
    } finally {
      _isInitialized = true;
      _recommendation = _computeLocalRecommendation();
      notifyListeners();
      // Silently sync recommendation in background without blocking UI
      _silentRefreshRecommendation();
    }
  }

  void _initDefaultData() {
    _setupNewLearnerCourseNodes();

    _leagueUsers = [
      LeagueUser(rank: 1, name: 'Arjun M.', xp: 1240, avatarColor: Colors.purple),
      LeagueUser(rank: 2, name: 'Priya K.', xp: 1180, avatarColor: Colors.teal),
      LeagueUser(rank: 3, name: '${_student.name} (You)', xp: _student.xp, avatarColor: const Color(0xFF00F0FF), isCurrentUser: true),
      LeagueUser(rank: 4, name: 'Rahul S.', xp: 980, avatarColor: Colors.orange),
      LeagueUser(rank: 5, name: 'Anu R.', xp: 910, avatarColor: Colors.pink),
      LeagueUser(rank: 6, name: 'Vikram B.', xp: 850, avatarColor: Colors.blue),
      LeagueUser(rank: 7, name: 'Neha D.', xp: 820, avatarColor: Colors.indigo),
    ];

    _achievements = [
      Achievement(
        id: 'ach_first',
        title: 'First Program',
        description: 'Complete your first executable program',
        icon: Icons.code,
        isUnlocked: false,
        progress: 0,
        total: 1,
      ),
      Achievement(
        id: 'ach_streak',
        title: '7-Day Coder',
        description: 'Maintain a 7-day learning streak',
        icon: Icons.local_fire_department,
        isUnlocked: false,
        progress: 0,
        total: 7,
      ),
      Achievement(
        id: 'ach_bughunter',
        title: 'Bug Hunter',
        description: 'Fix 10 AI-detected bugs and misconceptions',
        icon: Icons.pest_control,
        isUnlocked: false,
        progress: 0,
        total: 10,
      ),
      Achievement(
        id: 'ach_master',
        title: 'Concept Master',
        description: 'Reach 90% mastery on a core concept',
        icon: Icons.military_tech,
        isUnlocked: false,
        progress: 0,
        total: 1,
      ),
      Achievement(
        id: 'ach_speed',
        title: 'Speed Coder',
        description: 'Solve a challenge in under 60 seconds',
        icon: Icons.bolt,
        isUnlocked: false,
        progress: 0,
        total: 1,
      ),
      Achievement(
        id: 'ach_project',
        title: 'First Project',
        description: 'Complete your first capstone project',
        icon: Icons.rocket,
        isUnlocked: false,
        progress: 0,
        total: 1,
      ),
    ];

    _debugProblems = [
      DebugProblem(
        id: 'dbg_01',
        title: 'Missing Colon in Function',
        brokenCode: 'def square(n)\n    return n * n',
        errorType: 'SyntaxError: expected \':\'',
        hint: 'In Python, function headers must end with a colon (:)',
        expectedFix: 'def square(n):',
        xpReward: 20,
      ),
      DebugProblem(
        id: 'dbg_02',
        title: 'Off-By-One List Index',
        brokenCode: 'items = ["a", "b", "c"]\nprint(items[3])',
        errorType: 'IndexError: list index out of range',
        hint: 'Python lists use 0-based indexing. For 3 items, valid indices are 0, 1, 2.',
        expectedFix: 'print(items[2])',
        xpReward: 20,
      ),
      DebugProblem(
        id: 'dbg_03',
        title: 'Print vs Return in Discount',
        brokenCode: 'def discount(p):\n    print(p * 0.9)\n\ntotal = discount(100) + 10',
        errorType: 'TypeError: unsupported operand type for +: NoneType and int',
        hint: 'discount() prints the value but returns None. Change print() to return!',
        expectedFix: 'return p * 0.9',
        xpReward: 25,
      ),
    ];
  }

  IconData _iconForUnit(int unitNum) {
    switch (unitNum) {
      case 1: return Icons.terminal;
      case 2: return Icons.data_object;
      case 3: return Icons.text_fields;
      case 4: return Icons.calculate;
      case 5: return Icons.alt_route;
      case 6: return Icons.repeat;
      case 7: return Icons.psychology;
      case 8: return Icons.list_alt;
      case 9: return Icons.diamond;
      case 10: return Icons.menu_book;
      case 11: return Icons.lock;
      case 12: return Icons.bug_report;
      case 13: return Icons.folder;
      case 14: return Icons.build;
      case 15: return Icons.precision_manufacturing;
      case 16: return Icons.bolt;
      case 17: return Icons.castle;
      default: return Icons.code;
    }
  }

  void _setupCourseNodesFromCurriculum() {
    _courseNodes = [];
    bool hasCurrentNode = false;

    for (int i = 0; i < PythonCurriculumData.allUnits.length; i++) {
      final unit = PythonCurriculumData.allUnits[i];
      final isCompleted = _student.completedLessonIds.contains(unit.id) ||
          _student.completedLessonIds.contains('node_${unit.id.replaceFirst('unit_', '')}');

      NodeStatus status;
      double mastery = 0.0;
      int stars = 0;

      if (isCompleted) {
        status = NodeStatus.completed;
        mastery = 1.0;
        stars = 3;
      } else if (!hasCurrentNode) {
        status = NodeStatus.current;
        mastery = 0.0;
        stars = 0;
        hasCurrentNode = true;
      } else {
        status = NodeStatus.locked;
        mastery = 0.0;
        stars = 0;
      }

      _courseNodes.add(
        CourseNode(
          id: unit.id,
          title: unit.title,
          unitTitle: unit.unitTitle,
          icon: _iconForUnit(unit.unitNumber),
          status: status,
          masteryPercent: mastery,
          stars: stars,
          weekNumber: unit.weekNumber,
          weekTitle: unit.weekTitle,
          dayNumber: unit.dayNumber,
        ),
      );
    }
  }

  void _setupNewLearnerCourseNodes() {
    _setupCourseNodesFromCurriculum();
  }

  void _setupReturningCourseNodes() {
    _setupCourseNodesFromCurriculum();
  }

  /// Returns the first unfinished curriculum lesson, or the first if none completed
  StoryConcept get currentLesson {
    for (final unit in PythonCurriculumData.allUnits) {
      if (!_student.completedLessonIds.contains(unit.id)) {
        return unit;
      }
    }
    return PythonCurriculumData.allUnits.first;
  }

  /// 1-based index of current lesson
  int get currentLessonIndex {
    final idx = PythonCurriculumData.allUnits.indexWhere(
      (u) => !_student.completedLessonIds.contains(u.id),
    );
    return idx >= 0 ? idx + 1 : PythonCurriculumData.allUnits.length;
  }

  /// Total lessons in curriculum
  int get totalLessonsCount => PythonCurriculumData.allUnits.length;

  /// Real progress percentage based on actual completed lessons
  double get courseProgressPercent {
    if (PythonCurriculumData.allUnits.isEmpty) return 0.0;
    return _student.completedLessonIds.length / PythonCurriculumData.allUnits.length;
  }

  /// Calculates Next Best Learning Action locally with 0ms wait based strictly on real evidence
  Map<String, dynamic> _computeLocalRecommendation() {
    if (_student.isNewLearner) {
      return {
        'recommended_action': 'start_lesson',
        'concept': 'variables',
        'title': 'Python Foundations: Lesson 1',
        'reason': "Welcome to LearnIQ! Complete your first lesson so the AI can understand how you learn.",
        'estimated_time_minutes': 3,
        'priority_score': 1.0,
        'urgency_tag': '🟢 NEXT STEP',
      };
    }

    if (_student.activeMisconceptions.isNotEmpty) {
      final misc = _student.activeMisconceptions.first;
      return {
        'recommended_action': 'targeted_review',
        'concept': currentLesson.id,
        'title': 'Targeted Fix: $misc',
        'reason': 'Your recent interactive practice flagged: $misc. A 3-min repair drill will clear it up.',
        'estimated_time_minutes': 3,
        'priority_score': 0.94,
        'urgency_tag': '🔴 CRITICAL',
      };
    }

    if (_student.weakTopics.isNotEmpty) {
      final weak = _student.weakTopics.first;
      final topicName = weak.key;
      final retPct = (weak.value.retention * 100).toInt();
      return {
        'recommended_action': 'spaced_review',
        'concept': topicName,
        'title': 'Review: ${topicName.toUpperCase()}',
        'reason': 'Cognitive radar detected low retention ($retPct%) for $topicName. Quick practice will reinforce it.',
        'estimated_time_minutes': 3,
        'priority_score': 0.88,
        'urgency_tag': '🟡 REVIEW',
      };
    }

    final nextLesson = currentLesson;
    return {
      'recommended_action': 'continue_lesson',
      'concept': nextLesson.id,
      'title': '${nextLesson.unitTitle}: ${nextLesson.title}',
      'reason': 'Continue your sequential learning journey in Python.',
      'estimated_time_minutes': 4,
      'priority_score': 0.80,
      'urgency_tag': '🟢 CONTINUE',
    };
  }

  /// Fast local search query update
  void setSearchQuery(String query) {
    _searchQuery = query;
    AppLogger.course('Updated search query: "$query"');
    notifyListeners();
  }

  /// Filtered course nodes based on fast local index search
  List<CourseNode> get filteredCourseNodes {
    if (_searchQuery.trim().isEmpty) return _courseNodes;

    final matchedCurriculum = _repository.searchCurriculum(_searchQuery);
    final matchedIds = matchedCurriculum.map((c) => c.id).toSet();

    return _courseNodes.where((node) {
      if (matchedIds.contains(node.id)) return true;
      if (node.title.toLowerCase().contains(_searchQuery.toLowerCase())) return true;
      if (node.unitTitle.toLowerCase().contains(_searchQuery.toLowerCase())) return true;
      return false;
    }).toList();
  }

  Future<void> completeOnboarding({
    required String name,
    required String language,
    required int dailyGoal,
    required String experience,
  }) async {
    AppLogger.auth('Completing onboarding for $name ($language)');
    _isOnboardingComplete = true;
    _student = StudentState.newLearner(
      name: name.isNotEmpty ? name : "Alex",
      language: language,
      dailyGoal: dailyGoal,
      experience: experience,
    );
    _setupNewLearnerCourseNodes();
    _recommendation = _computeLocalRecommendation();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('user_name', _student.name);
      await prefs.setInt('user_xp', _student.xp);
      await prefs.setInt('user_streak', _student.streak);
      await prefs.setInt('user_level', _student.level);
    } catch (e) {
      AppLogger.auth('Error saving onboarding state: $e');
    }

    notifyListeners();
  }

  Future<void> resetToNewUser() async {
    AppLogger.auth('Resetting session to brand-new user');
    _isOnboardingComplete = false;
    _student = StudentState.newLearner();
    _setupNewLearnerCourseNodes();
    _recommendation = _computeLocalRecommendation();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', false);
      await prefs.clear();
    } catch (e) {
      AppLogger.auth('Error clearing session: $e');
    }

    notifyListeners();
  }

  Future<void> switchToReturningUserDemo() async {
    AppLogger.auth('Switching session to Level 3 Returning User Demo');
    _isOnboardingComplete = true;
    _student = StudentState.demoReturningUser();
    _setupReturningCourseNodes();
    _recommendation = _computeLocalRecommendation();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('user_name', _student.name);
      await prefs.setInt('user_xp', _student.xp);
      await prefs.setInt('user_streak', _student.streak);
      await prefs.setInt('user_level', _student.level);
    } catch (e) {
      AppLogger.auth('Error saving demo state: $e');
    }

    notifyListeners();
    _silentRefreshRecommendation();
  }

  /// Refreshes recommendation without blocking UI or showing global loader
  Future<void> refreshRecommendation() async {
    _recommendation = _computeLocalRecommendation();
    notifyListeners();
    _silentRefreshRecommendation();
  }

  void _silentRefreshRecommendation() {
    if (_student.isNewLearner) return;
    ApiService.getRecommendationAsync().then((backendRec) {
      if (backendRec != null && !_student.isNewLearner) {
        _recommendation = backendRec;
        notifyListeners();
      }
    });
  }

  /// Adds experience points directly and updates league rank
  void addExperience(int xp) {
    final int newXp = _student.xp + xp;
    _student = _student.copyWith(xp: newXp);
    _updateLeagueUserXp(newXp);
    notifyListeners();
    _persistLocalState();
  }

  /// Alias for completing a lesson/unit with custom XP bonus
  void completeLesson(String nodeId, {int xpBonus = 50}) {
    completeLessonNode(nodeId, xpBonus);
  }

  /// Completes a lesson node on course map and unlocks next skill immediately
  /// Idempotent: Awards full XP on first completion, prevents duplicate rewards on repeat runs
  void completeLessonNode(String nodeId, int xpGained) {
    final bool isFirstCompletion = !_student.completedLessonIds.contains(nodeId);
    final int effectiveXp = isFirstCompletion ? xpGained : 5; // Review XP if repeated

    AppLogger.course('Completing lesson node: $nodeId (firstCompletion: $isFirstCompletion, +${effectiveXp}XP)');

    int nextNodeIndex = -1;
    for (int i = 0; i < _courseNodes.length; i++) {
      if (_courseNodes[i].id == nodeId) {
        _courseNodes[i] = CourseNode(
          id: _courseNodes[i].id,
          title: _courseNodes[i].title,
          unitTitle: _courseNodes[i].unitTitle,
          icon: _courseNodes[i].icon,
          status: NodeStatus.completed,
          masteryPercent: 1.0,
          stars: 3,
        );
        nextNodeIndex = i + 1;
        break;
      }
    }

    if (nextNodeIndex >= 0 && nextNodeIndex < _courseNodes.length) {
      if (_courseNodes[nextNodeIndex].status == NodeStatus.locked) {
        _courseNodes[nextNodeIndex] = CourseNode(
          id: _courseNodes[nextNodeIndex].id,
          title: _courseNodes[nextNodeIndex].title,
          unitTitle: _courseNodes[nextNodeIndex].unitTitle,
          icon: _courseNodes[nextNodeIndex].icon,
          status: NodeStatus.current,
          masteryPercent: 0.10,
          stars: 0,
        );
      }
    }

    // Award XP and streak locally & instantly
    int newXp = _student.xp + effectiveXp;
    int newStreak = _student.streak == 0 ? 1 : _student.streak;
    int newDailyMin = (_student.dailyProgressMinutes + 4).clamp(0, _student.dailyGoalMinutes);

    final updatedCompletedIds = List<String>.from(_student.completedLessonIds);
    if (isFirstCompletion) {
      updatedCompletedIds.add(nodeId);
    }

    _updateLeagueUserXp(newXp);

    _student = _student.copyWith(
      xp: newXp,
      streak: newStreak,
      dailyProgressMinutes: newDailyMin,
      completedLessonIds: updatedCompletedIds,
    );

    // Update First Program achievement
    _achievements = _achievements.map((a) {
      if (a.id == 'ach_first') {
        return Achievement(
          id: a.id,
          title: a.title,
          description: a.description,
          icon: a.icon,
          isUnlocked: true,
          progress: 1,
          total: 1,
        );
      }
      return a;
    }).toList();

    _recommendation = _computeLocalRecommendation();
    notifyListeners();

    // Persist and queue background sync via repository
    _persistLocalState();
    _repository.enqueueEvent(
      type: 'LESSON_COMPLETED',
      payload: {
        'node_id': nodeId,
        'xp_gained': effectiveXp,
        'is_first_completion': isFirstCompletion,
      },
    );
  }

  void deductHeart() {
    if (_student.hearts > 0) {
      _student = _student.copyWith(hearts: _student.hearts - 1);
      AppLogger.lesson('Deducted heart. Remaining: ${_student.hearts}');
      notifyListeners();
      _persistLocalState();
    }
  }

  void refillHearts() {
    _student = _student.copyWith(hearts: _student.maxHearts);
    AppLogger.lesson('Hearts refilled to max');
    notifyListeners();
    _persistLocalState();
  }

  void rechargeEnergy() {
    _student = _student.copyWith(energy: 100);
    AppLogger.lesson('Energy recharged to 100');
    notifyListeners();
    _persistLocalState();
  }

  /// Instant, 0ms local answer evaluation & Twin update (never blocks the UI)
  Map<String, dynamic> submitAnswer({
    required String exerciseId,
    required String concept,
    required String questionType,
    required String studentAnswer,
    String? codeContext,
    String? expectedAnswer,
  }) {
    AppLogger.lesson('Evaluating answer locally: $exerciseId ($concept)');

    // Instant local evaluation (0 ms latency)
    final result = ApiService.localEvaluate(
      exerciseId: exerciseId,
      concept: concept,
      studentAnswer: studentAnswer,
      codeContext: codeContext,
      expectedAnswer: expectedAnswer,
    );

    final bool isCorrect = result['correct'] == true;
    final int xpGain = (result['xp_earned'] as num?)?.toInt() ?? (isCorrect ? 10 : 0);
    final int gemGain = (result['gems_earned'] as num?)?.toInt() ?? (isCorrect ? 2 : 0);
    final double newMastery = (result['new_mastery'] as num?)?.toDouble() ?? 0.58;

    int nextEnergy = _student.energy;
    int nextHearts = _student.hearts;
    if (!isCorrect) {
      if (nextEnergy >= 10) nextEnergy -= 10;
      if (nextHearts > 0) nextHearts -= 1;
    }

    final updatedConcepts = Map<String, ConceptMastery>.from(_student.concepts);
    if (updatedConcepts.containsKey(concept)) {
      final current = updatedConcepts[concept]!;
      updatedConcepts[concept] = current.copyWith(
        mastery: newMastery,
        retention: isCorrect ? (current.retention + 0.05).clamp(0.0, 1.0) : current.retention,
        successCount: isCorrect ? current.successCount + 1 : current.successCount,
        mistakeCount: isCorrect ? current.mistakeCount : current.mistakeCount + 1,
      );
    } else {
      updatedConcepts[concept] = ConceptMastery(
        mastery: newMastery,
        retention: isCorrect ? 0.70 : 0.40,
        confidence: isCorrect ? 0.80 : 0.40,
        successCount: isCorrect ? 1 : 0,
        mistakeCount: isCorrect ? 0 : 1,
      );
    }

    final activeMisc = List<String>.from(_student.activeMisconceptions);
    final resolvedMisc = List<String>.from(_student.resolvedMisconceptions);

    if (result['misconception_detected'] == true) {
      final m = result['misconception'] as String?;
      if (m != null && !activeMisc.contains(m)) {
        activeMisc.add(m);
        AppLogger.ai('AI Misconception flagged locally: $m');
      }
    }

    if (result['misconception'] != null && result['misconception'].toString().contains('Resolved')) {
      activeMisc.removeWhere((item) => item.contains('print with return'));
      if (!resolvedMisc.contains('confusing print with return')) {
        resolvedMisc.add('confusing print with return');
      }
      _updateCourseNodeMastery('node_functions', 0.86, 2);
      AppLogger.ai('Misconception resolved! Functions mastery surged to 86%');
    }

    int newXp = _student.xp + xpGain;
    _updateLeagueUserXp(newXp);

    _student = _student.copyWith(
      xp: newXp,
      gems: _student.gems + gemGain,
      energy: nextEnergy,
      hearts: nextHearts,
      concepts: updatedConcepts,
      activeMisconceptions: activeMisc,
      resolvedMisconceptions: resolvedMisc,
    );

    _recommendation = _computeLocalRecommendation();
    notifyListeners();

    // Persist state locally and queue in offline event repository
    _persistLocalState();
    _repository.enqueueEvent(
      type: 'ANSWER_SUBMITTED',
      payload: {
        'exercise_id': exerciseId,
        'concept': concept,
        'question_type': questionType,
        'student_answer': studentAnswer,
        'code_context': codeContext,
        'expected_answer': expectedAnswer,
        'is_correct': isCorrect,
        'xp_earned': xpGain,
      },
    );

    return result;
  }

  void _updateCourseNodeMastery(String nodeId, double mastery, int stars) {
    _courseNodes = _courseNodes.map((node) {
      if (node.id == nodeId) {
        return CourseNode(
          id: node.id,
          title: node.title,
          unitTitle: node.unitTitle,
          icon: node.icon,
          status: NodeStatus.completed,
          masteryPercent: mastery,
          stars: stars,
        );
      }
      return node;
    }).toList();
  }

  void _updateLeagueUserXp(int newXp) {
    _leagueUsers = _leagueUsers.map((u) {
      if (u.isCurrentUser) {
        return LeagueUser(
          rank: u.rank,
          name: u.name,
          xp: newXp,
          avatarColor: u.avatarColor,
          isCurrentUser: true,
        );
      }
      return u;
    }).toList();
    _leagueUsers.sort((a, b) => b.xp.compareTo(a.xp));
  }

  void unlockNextSkill() {
    completeLessonNode('node_functions', 50);
  }

  Future<void> _persistLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _student.name);
      await prefs.setInt('user_xp', _student.xp);
      await prefs.setInt('user_streak', _student.streak);
      await prefs.setInt('user_level', _student.level);
      await prefs.setInt('user_daily_progress', _student.dailyProgressMinutes);
      await prefs.setStringList('user_completed_lessons', _student.completedLessonIds);
      await prefs.setStringList('user_active_misconceptions', _student.activeMisconceptions);
      await prefs.setStringList('user_resolved_misconceptions', _student.resolvedMisconceptions);

      final conceptsMap = _student.concepts.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString('user_concepts_json', jsonEncode(conceptsMap));
    } catch (e) {
      AppLogger.sync('Failed to write local SharedPreferences: $e');
    }
  }

  /// Safe reset of corrupted or demo learning state to brand-new baseline
  Future<void> resetLearningState() async {
    AppLogger.auth('Explicitly resetting all learning state to zero');
    _student = StudentState.newLearner();
    _setupNewLearnerCourseNodes();
    _recommendation = _computeLocalRecommendation();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_xp');
      await prefs.remove('user_streak');
      await prefs.remove('user_level');
      await prefs.remove('user_daily_progress');
      await prefs.remove('user_completed_lessons');
      await prefs.remove('user_concepts_json');
      await prefs.remove('user_active_misconceptions');
      await prefs.remove('user_resolved_misconceptions');
      await prefs.remove('offline_event_queue');
    } catch (e) {
      AppLogger.auth('Error resetting state: $e');
    }

    notifyListeners();
  }
}
