import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/verified_explanation_card.dart';
import '../../main.dart';

class FirstLessonScreen extends StatefulWidget {
  final LearningStateManager stateManager;

  const FirstLessonScreen({super.key, required this.stateManager});

  @override
  State<FirstLessonScreen> createState() => _FirstLessonScreenState();
}

class _FirstLessonScreenState extends State<FirstLessonScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  List<String> _orderedBlocks = [];
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  String _feedbackText = '';
  int _totalXpEarned = 0;
  bool _isLessonFinished = false;

  final List<Map<String, dynamic>> _exercises = [
    // 1. First introductory question
    {
      'type': 'output_prediction',
      'title': 'Meet Your First Variable',
      'prompt': 'What will this Python code output?',
      'code': 'name = "Alex"\nprint(name)',
      'options': ['Alex', 'name', '"Alex"', 'Error'],
      'correct': 'Alex',
      'explanation': 'name = "Alex" stores "Alex" in a variable. print(name) outputs its value: Alex.',
    },
    // 2. Intuition Check: Variable updating
    {
      'type': 'output_prediction',
      'title': 'Changing Values',
      'prompt': 'Variables can change! What does this code print?',
      'code': 'x = 5\nx = x + 2\nprint(x)',
      'options': ['5', '7', 'x + 2', 'Error'],
      'correct': '7',
      'explanation': 'x starts as 5, then x + 2 evaluates to 7 and updates x. print(x) prints 7.',
    },
    // 3. Fill in the blank
    {
      'type': 'multiple_choice',
      'title': 'Matching Names',
      'prompt': 'Choose the missing variable name so it prints correctly:',
      'code': '_____ = "Alex"\nprint(user)',
      'options': ['user', 'name', 'x', 'str'],
      'correct': 'user',
      'explanation': 'The variable assigned on the left must match the name printed inside print().',
    },
    // 4. Code Ordering
    {
      'type': 'code_ordering',
      'title': 'Build Your First Program',
      'prompt': 'Tap lines to order your first runnable program:',
      'code': null,
      'blocks': ['print(greeting)', 'greeting = "Hello, Coder!"'],
      'correct_order': ['greeting = "Hello, Coder!"', 'print(greeting)'],
      'explanation': 'Python executes top-to-bottom. You must define a variable before printing it!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _resetCurrentExerciseState();
  }

  void _resetCurrentExerciseState() {
    _selectedOption = null;
    _isAnswerChecked = false;
    _isCorrect = false;
    _feedbackText = '';
    final ex = _exercises[_currentIndex];
    if (ex['type'] == 'code_ordering') {
      _orderedBlocks = List<String>.from(ex['blocks'] as List<String>)..shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLessonFinished) {
      return _buildCompletionCelebration();
    }

    final ex = _exercises[_currentIndex];
    final double progress = (_currentIndex + 1) / _exercises.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (ctx) => MainNavigationHost(stateManager: widget.stateManager),
              ),
              (route) => false,
            );
          },
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
                const Icon(Icons.favorite, color: AppColors.misconceptionRed, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.stateManager.student.hearts}',
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
                    const SizedBox(height: 6),
                    Text(
                      ex['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ex['prompt'],
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    if (ex['code'] != null) ...[
                      Container(
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
                            const SizedBox(height: 10),
                            Text(
                              ex['code'],
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 15,
                                color: const Color(0xFFE6EDF3),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Exercise Input Area
                    if (ex['type'] == 'code_ordering') ...[
                      const Text(
                        'Drag or tap lines to arrange them in order:',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.drag_indicator, color: AppColors.textMuted, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _orderedBlocks[i],
                                      style: GoogleFonts.jetBrainsMono(fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ] else ...[
                      // Multiple Choice / Output Prediction
                      for (final opt in (ex['options'] as List<String>))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: _isAnswerChecked
                                ? null
                                : () {
                                    setState(() {
                                      _selectedOption = opt;
                                    });
                                  },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _selectedOption == opt
                                    ? AppColors.iqooCyan.withValues(alpha: 0.12)
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedOption == opt ? AppColors.iqooCyan : AppColors.border,
                                  width: _selectedOption == opt ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedOption == opt ? AppColors.iqooCyan : AppColors.textMuted,
                                        width: 2,
                                      ),
                                      color: _selectedOption == opt ? AppColors.iqooCyan : Colors.transparent,
                                    ),
                                    child: _selectedOption == opt
                                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 15,
                                        fontWeight: _selectedOption == opt ? FontWeight.bold : FontWeight.w500,
                                        color: _selectedOption == opt ? AppColors.iqooCyan : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action bar
            _buildBottomActionBar(ex),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(Map<String, dynamic> ex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAnswerChecked) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.duolingoGreen.withValues(alpha: 0.15)
                    : AppColors.misconceptionRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.error_outline,
                    color: _isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _feedbackText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerifiedSourceBadge(
              sourceTitle: 'Python Tutorial (3.13) - First Steps & Variables',
              sourceUrl: 'https://docs.python.org/3/tutorial/introduction.html#using-python-as-a-calculator',
              pythonVersion: 'Python 3.13',
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isAnswerChecked
                  ? () => _handleNext()
                  : (_selectedOption != null || ex['type'] == 'code_ordering')
                      ? () => _handleCheck(ex)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswerChecked
                    ? (_isCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed)
                    : AppColors.duolingoGreen,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _isAnswerChecked
                    ? (_currentIndex < _exercises.length - 1 ? 'CONTINUE →' : 'COMPLETE LESSON 🎉')
                    : 'CHECK ANSWER',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheck(Map<String, dynamic> ex) {
    bool correct = false;
    if (ex['type'] == 'code_ordering') {
      final correctOrder = ex['correct_order'] as List<String>;
      correct = _orderedBlocks.join('\n') == correctOrder.join('\n');
    } else {
      correct = _selectedOption == ex['correct'];
    }

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = correct;
      if (correct) {
        _totalXpEarned += 10;
        _feedbackText = 'Correct! 🎉 +10 XP\n${ex['explanation']}';
      } else {
        widget.stateManager.deductHeart();
        _feedbackText = 'Not quite.\n${ex['explanation']}';
      }
    });
  }

  void _handleNext() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _resetCurrentExerciseState();
      });
    } else {
      // Complete lesson 1: Variables node
      widget.stateManager.completeLessonNode('node_vars', _totalXpEarned + 10);
      setState(() {
        _isLessonFinished = true;
      });
    }
  }

  Widget _buildCompletionCelebration() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.duolingoGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'FIRST LESSON COMPLETE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You wrote and verified your first Python variables! Your streak has officially started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),

              // Rewards summary
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
                    _buildCelebrationTile('+$_totalXpEarned XP', 'XP EARNED', AppColors.xpAmber),
                    _buildCelebrationTile('🔥 1 Day', 'STREAK', AppColors.streakFlame),
                    _buildCelebrationTile('100% 🟢', 'VARIABLES', AppColors.duolingoGreen),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Achievement unlocked banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.xpAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.xpAmber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.military_tech, color: AppColors.xpAmber, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACHIEVEMENT UNLOCKED 🏆',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.xpAmber),
                          ),
                          Text(
                            'First Program: Complete your first executable program',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => MainNavigationHost(stateManager: widget.stateManager),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'CONTINUE TO COURSE MAP ➔',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationTile(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
