import 'package:flutter/material.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import 'daily_goal_screen.dart';

class ExperienceLevelScreen extends StatefulWidget {
  final LearningStateManager stateManager;
  final String selectedLanguage;

  const ExperienceLevelScreen({
    super.key,
    required this.stateManager,
    required this.selectedLanguage,
  });

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  String _selectedLevel = 'new';

  final List<Map<String, String>> _levels = [
    {
      'id': 'new',
      'icon': '🌱',
      'title': "I'm completely new",
      'subtitle': "I've never written a line of code before.",
    },
    {
      'id': 'basics',
      'icon': '🌿',
      'title': "I've tried coding",
      'subtitle': "I know variables and simple logic.",
    },
    {
      'id': 'comfortable',
      'icon': '🚀',
      'title': "I'm comfortable coding",
      'subtitle': "I want to master algorithms and problem solving.",
    },
    {
      'id': 'advanced',
      'icon': '⚡',
      'title': "I'm advanced",
      'subtitle': "I want fast-paced, high-difficulty challenges.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'STEP 2 OF 4',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.iqooCyan,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What's your coding experience?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "LearnIQ adapts the difficulty and tone of explanations to your background.",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    final lvl = _levels[index];
                    final isSelected = _selectedLevel == lvl['id'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLevel = lvl['id']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.iqooCyan.withValues(alpha: 0.12)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.iqooCyan : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(lvl['icon']!, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lvl['title']!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      lvl['subtitle']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.iqooCyan, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => DailyGoalScreen(
                          stateManager: widget.stateManager,
                          selectedLanguage: widget.selectedLanguage,
                          experienceLevel: _selectedLevel,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
