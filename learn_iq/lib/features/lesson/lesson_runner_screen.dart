import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';

class LessonRunnerScreen extends StatefulWidget {
  final LearningStateManager stateManager;
  final bool isTargetedFixLaunch;

  const LessonRunnerScreen({
    super.key,
    required this.stateManager,
    this.isTargetedFixLaunch = false,
  });

  @override
  State<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

class _LessonRunnerScreenState extends State<LessonRunnerScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  List<String> _orderedBlocks = [];
  bool _isAnswerChecked = false;
  Map<String, dynamic>? _evaluationResult;
  bool _isLessonComplete = false;
  int _sessionXpGained = 0;

  // The Curated Golden Demo Micro-Exercises for Python Functions
  late final List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _initExercises();
    if (widget.isTargetedFixLaunch) {
      // Jump directly to the Golden Misconception Exercise
      _currentIndex = 1;
    }
  }

  void _initExercises() {
    _exercises = [
      // 1. Output prediction
      Exercise(
        id: 'fx_ex_01',
        concept: 'functions',
        type: ExerciseType.outputPrediction,
        questionPrompt: 'What does this Python code output?',
        codeSnippet: 'def greet(name):\n    return "Hi " + name\n\nmessage = greet("Gopi")\nprint(message)',
        options: ['Hi Gopi', 'name', 'None', 'Hi name'],
        correctOption: 'Hi Gopi',
        expectedAnswer: 'Hi Gopi',
        explanation: 'greet("Gopi") returns "Hi Gopi", which is stored in message and printed.',
      ),

      // 2. THE SIGNATURE WOW MOMENT: print vs return misconception
      Exercise(
        id: 'fx_ex_02_wow',
        concept: 'functions',
        type: ExerciseType.outputPrediction,
        questionPrompt: 'Carefully predict the exact output of this code:',
        codeSnippet: 'def add(a, b):\n    print(a + b)\n\nresult = add(5, 10)\nprint(result)',
        options: ['15', 'None', '15\nNone', 'SyntaxError'],
        correctOption: '15\nNone',
        expectedAnswer: '15\nNone',
        explanation: 'add(5, 10) prints 15 inside the function. Since there is no return statement, result is assigned None! Then print(result) outputs None.',
      ),

      // 3. Code Ordering Exercise
      Exercise(
        id: 'fx_ex_03_order',
        concept: 'functions',
        type: ExerciseType.codeOrdering,
        questionPrompt: 'Arrange the lines to build a function that doubles a number and returns it:',
        orderBlocks: [
          'def double(n):',
          '    return n * 2',
          'ans = double(4)',
          'print(ans)',
        ],
        correctOrder: [
          'def double(n):',
          '    return n * 2',
          'ans = double(4)',
          'print(ans)',
        ],
      ),

      // 4. Fill in the Blank
      Exercise(
        id: 'fx_ex_04_fill',
        concept: 'functions',
        type: ExerciseType.fillBlank,
        questionPrompt: 'Fill in the keyword that sends the calculation back to the caller:',
        codeSnippet: 'def multiply(x, y):\n    ______ x * y',
        options: ['return', 'print', 'send', 'output'],
        correctOption: 'return',
        expectedAnswer: 'return',
        explanation: "'return' is the Python keyword that outputs data from a function.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLessonComplete) {
      return _buildCelebrationScreen();
    }

    final currentExercise = _exercises[_currentIndex];
    final double progress = (_currentIndex + 1) / _exercises.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.duolingoGreen),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.energyOrange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.stateManager.student.energy}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUESTION ${_currentIndex + 1} OF ${_exercises.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.iqooCyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentExercise.questionPrompt,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Code Snippet Card (if applicable)
                    if (currentExercise.codeSnippet != null)
                      _buildCodeSnippetCard(currentExercise.codeSnippet!),

                    const SizedBox(height: 20),

                    // Exercise Content by Type
                    _buildExerciseBody(currentExercise),
                  ],
                ),
              ),
            ),

            // Bottom Action & Feedback Area
            _buildBottomBar(currentExercise),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeSnippetCard(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
              const Spacer(),
              const Text('python', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            code,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: const Color(0xFFE6EDF3),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBody(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.outputPrediction:
      case ExerciseType.multipleChoice:
      case ExerciseType.fillBlank:
        return Column(
          children: (exercise.options ?? []).map((option) {
            final isSelected = _selectedOption == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: _isAnswerChecked
                    ? null
                    : () {
                        setState(() {
                          _selectedOption = option;
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.iqooCyan.withValues(alpha: 0.12) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.iqooCyan : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.iqooCyan : AppColors.textMuted,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.iqooCyan : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.iqooCyan : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case ExerciseType.codeOrdering:
        final blocks = exercise.orderBlocks ?? [];
        if (_orderedBlocks.isEmpty) {
          _orderedBlocks = List.from(blocks)..shuffle();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap lines in the correct logical execution order:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _orderedBlocks.removeAt(oldIndex);
                  _orderedBlocks.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _orderedBlocks.length; i++)
                  Container(
                    key: ValueKey(_orderedBlocks[i]),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator, color: AppColors.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _orderedBlocks[i],
                            style: GoogleFonts.jetBrainsMono(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(Exercise currentExercise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // If checked, show feedback or Misconception Wow Card
          if (_isAnswerChecked && _evaluationResult != null) ...[
            _buildFeedbackMessage(_evaluationResult!),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isAnswerChecked
                  ? () => _handleNextQuestion()
                  : (_selectedOption != null || currentExercise.type == ExerciseType.codeOrdering)
                      ? () => _handleCheckAnswer(currentExercise)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswerChecked
                    ? (_evaluationResult?['correct'] == true
                        ? AppColors.duolingoGreen
                        : AppColors.misconceptionRed)
                    : AppColors.duolingoGreen,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _isAnswerChecked
                    ? (_currentIndex < _exercises.length - 1 ? 'CONTINUE →' : 'FINISH LESSON 🎉')
                    : 'CHECK ANSWER',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckAnswer(Exercise exercise) {
    String studentAnswer = _selectedOption ?? '';
    if (exercise.type == ExerciseType.codeOrdering) {
      studentAnswer = _orderedBlocks.join('\n');
    }

    final res = widget.stateManager.submitAnswer(
      exerciseId: exercise.id,
      concept: exercise.concept,
      questionType: exercise.type.name,
      studentAnswer: studentAnswer,
      codeContext: exercise.codeSnippet,
      expectedAnswer: exercise.expectedAnswer,
    );

    setState(() {
      _isAnswerChecked = true;
      _evaluationResult = res;
      _sessionXpGained += (res['xp_earned'] as num?)?.toInt() ?? 0;
    });

    // If Misconception Detected (e.g. print vs return on Exercise 2)
    if (res['misconception_detected'] == true) {
      _showMisconceptionInterventionModal(res);
    }
  }

  void _handleNextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _orderedBlocks = [];
        _isAnswerChecked = false;
        _evaluationResult = null;
      });
    } else {
      setState(() {
        _isLessonComplete = true;
      });
    }
  }

  Widget _buildFeedbackMessage(Map<String, dynamic> result) {
    final bool isCorrect = result['correct'] == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.duolingoGreen.withValues(alpha: 0.15)
            : AppColors.misconceptionRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.error_outline,
            color: isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result['feedback'] ?? (isCorrect ? 'Correct! +10 XP' : 'Incorrect answer.'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// THE SIGNATURE WOW MOMENT MODAL
  void _showMisconceptionInterventionModal(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.misconceptionRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.psychology, color: AppColors.misconceptionRed, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI MISCONCEPTION DETECTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.misconceptionRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You understand function parameters,\nbut you\'re confusing print() with return().',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
              ),
              const SizedBox(height: 14),

              // Concept Contrast Cards
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildContrastRow('print()', 'Displays value to screen output only. Returns None.'),
                    const Divider(color: AppColors.border, height: 16),
                    _buildContrastRow('return', 'Sends value back to caller so result can store it.'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Targeted Repair Exercise
              const Text(
                'TARGETED FIX: Replace print() with return so result holds 15:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.iqooCyan),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'def add(a, b):\n    return a + b  # Fixed!\n\nresult = add(5, 10)',
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.duolingoGreen),
                ),
              ),
              const SizedBox(height: 20),

              // Button to Apply Targeted Repair
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Submit resolution immediately locally and sync in background
                    widget.stateManager.submitAnswer(
                      exerciseId: 'fx_print_return_02',
                      concept: 'functions',
                      questionType: 'bug_fix',
                      studentAnswer: 'return a + b',
                    );
                    setState(() {
                      _sessionXpGained += 25;
                      _evaluationResult = {
                        'correct': true,
                        'feedback': '🎉 Brilliant! Misconception Resolved. Functions mastery surged from 58% → 86% (+25 XP)!',
                      };
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'APPLY TARGETED FIX & RESOLVE (+25 XP)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContrastRow(String code, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.iqooCyan,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationScreen() {
    final student = widget.stateManager.student;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'LESSON COMPLETE!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You mastered Python Functions and resolved the print vs return misconception!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // Stats summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryTile('XP EARNED', '+$_sessionXpGained XP', AppColors.xpAmber),
                    _buildSummaryTile('STREAK', '${student.streak} Days 🔥', AppColors.streakFlame),
                    _buildSummaryTile('MASTERY', '86% 🟢', AppColors.duolingoGreen),
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.stateManager.unlockNextSkill();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'CONTINUE TO COURSE MAP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ],
    );
  }
}
