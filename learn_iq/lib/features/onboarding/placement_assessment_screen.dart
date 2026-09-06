import 'package:flutter/material.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../lesson/first_lesson_screen.dart';

class PlacementAssessmentScreen extends StatelessWidget {
  final LearningStateManager stateManager;
  final String selectedLanguage;
  final String experienceLevel;
  final int dailyGoal;

  const PlacementAssessmentScreen({
    super.key,
    required this.stateManager,
    required this.selectedLanguage,
    required this.experienceLevel,
    required this.dailyGoal,
  });

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
          'STEP 4 OF 4',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How do you want to start?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You can always start from Level 1 or take a short placement check.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // Option 1: START FROM THE BEGINNING (Hero Card)
              InkWell(
                onTap: () async {
                  await stateManager.completeOnboarding(
                    name: 'Alex',
                    language: selectedLanguage,
                    dailyGoal: dailyGoal,
                    experience: experienceLevel,
                  );

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => FirstLessonScreen(stateManager: stateManager),
                      ),
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.duolingoGreen.withValues(alpha: 0.15),
                        AppColors.card,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.duolingoGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.duolingoGreen.withValues(alpha: 0.1),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.duolingoGreen.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🌱', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'START FROM THE BEGINNING',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.duolingoGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Start with Python variables and build intuition step by step. Ideal for all beginners.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.duolingoGreen, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Option 2: Placement test
              InkWell(
                onTap: () async {
                  await stateManager.completeOnboarding(
                    name: 'Alex',
                    language: selectedLanguage,
                    dailyGoal: dailyGoal,
                    experience: experienceLevel,
                  );

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => FirstLessonScreen(stateManager: stateManager),
                      ),
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('⚡', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'TAKE A QUICK 2-MIN TEST',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Unlock earlier units if you already know Python syntax.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Your Learning Twin will initialize right after Lesson 1.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
