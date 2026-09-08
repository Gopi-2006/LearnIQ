import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../lesson/first_lesson_screen.dart';
import '../iqoo_features/code_scanner_dialog.dart';
import '../iqoo_features/teach_back_sheet.dart';
import '../lesson/engine/ask_learn_iq_sheet.dart';
import '../lesson/engine/lesson_engine_screen.dart';
import '../practice/weak_areas_screen.dart';
import '../../screens/ask_learniq_screen.dart';

class HomeScreen extends StatelessWidget {
  final LearningStateManager stateManager;
  final Function(int) onTabChange;

  const HomeScreen({
    super.key,
    required this.stateManager,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final student = stateManager.student;
    final rec = stateManager.recommendation;
    final bool isNewLearner = student.isNewLearner;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.iqooCyan,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            await stateManager.refreshRecommendation();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER & GAMIFICATION STATS ROW
                _buildTopStatsBar(context, student),
                const SizedBox(height: 14),

                // 2. iQOO MONSTER NPU ENGINE BANNER
                _buildIqooNpuBanner(context),
                const SizedBox(height: 16),

                // 3. MAIN HERO: START / CONTINUE LEARNING
                if (isNewLearner)
                  _buildStartFirstLessonCard(context)
                else
                  _buildContinueLearningCard(context),
                const SizedBox(height: 16),

                // 4. CORE HERO FEATURE: NEXT BEST LEARNING ACTION
                _buildNextBestActionCard(context, rec, isNewLearner),
                const SizedBox(height: 16),

                // 5. DAILY GOAL PROGRESS
                _buildDailyGoalCard(student),
                const SizedBox(height: 16),

                // 6. QUICK SUMMARY OF LEARNING TWIN
                _buildLearningTwinSummary(context, student, isNewLearner),
                const SizedBox(height: 16),

                // 7. QUICK PRACTICE & iQOO CAPABILITIES
                _buildQuickActionsRow(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING ☀️';
    if (hour < 17) return 'GOOD AFTERNOON 👋';
    return 'GOOD EVENING 🌙';
  }

  Widget _buildTopStatsBar(BuildContext context, StudentState student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, size: 16, color: AppColors.iqooCyan),
                  const SizedBox(width: 4),
                  Text(
                    'Lvl ${student.level} ${student.levelTitle}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Gamification Counters: Streak, Hearts, Energy, Gems
        Row(
          children: [
            // Streak
            Expanded(
              child: _buildStatChip(
                icon: Icons.local_fire_department,
                iconColor: AppColors.streakFlame,
                value: '${student.streak}',
                label: 'STREAK',
                bgColor: const Color(0xFF2A1515),
                borderColor: AppColors.streakFlame.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 6),
            // Hearts
            Expanded(
              child: InkWell(
                onTap: () => stateManager.refillHearts(),
                borderRadius: BorderRadius.circular(12),
                child: _buildStatChip(
                  icon: Icons.favorite,
                  iconColor: AppColors.misconceptionRed,
                  value: '${student.hearts}',
                  label: 'HEARTS',
                  bgColor: const Color(0xFF2A121A),
                  borderColor: AppColors.misconceptionRed.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Energy
            Expanded(
              child: InkWell(
                onTap: () => stateManager.rechargeEnergy(),
                borderRadius: BorderRadius.circular(12),
                child: _buildStatChip(
                  icon: Icons.bolt,
                  iconColor: AppColors.energyOrange,
                  value: '${student.energy}',
                  label: 'ENERGY',
                  bgColor: const Color(0xFF2A1F10),
                  borderColor: AppColors.energyOrange.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Gems
            Expanded(
              child: _buildStatChip(
                icon: Icons.diamond,
                iconColor: AppColors.gemBlue,
                value: '${student.gems}',
                label: 'GEMS',
                bgColor: const Color(0xFF101B2E),
                borderColor: AppColors.gemBlue.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIqooNpuBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.iqooCyan.withValues(alpha: 0.12),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.iqooCyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on, color: AppColors.iqooCyan, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: 'LEARNIQ AI ENGINE  ',
                    style: TextStyle(
                      color: AppColors.iqooCyan,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  TextSpan(text: 'Adaptive On-Device Learning • 100% Offline'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartFirstLessonCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.duolingoGreen.withValues(alpha: 0.15),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.duolingoGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.duolingoGreen.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.duolingoGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🌱', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'START YOUR FIRST LESSON',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.duolingoGreen,
                    ),
                  ),
                  Text(
                    'Python Basics: Variables',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Meet your first Python variable! Takes only 3 minutes to earn your first XP and start your streak.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => FirstLessonScreen(stateManager: stateManager),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.duolingoGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'START LESSON 1 ➔',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningCard(BuildContext context) {
    final lesson = stateManager.currentLesson;
    final lessonIdx = stateManager.currentLessonIndex;
    final totalLessons = stateManager.totalLessonsCount;
    final progress = stateManager.courseProgressPercent;
    final int pct = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(lesson.themeEmoji.isNotEmpty ? lesson.themeEmoji : '🐍', style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONTINUE LEARNING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            lesson.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lesson $lessonIdx of $totalLessons',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.duolingoGreen),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% Completed',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => LessonEngineScreen(
                        concept: lesson,
                        stateManager: stateManager,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.duolingoGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextBestActionCard(BuildContext context, Map<String, dynamic>? rec, bool isNewLearner) {
    final String title = isNewLearner
        ? 'Python Foundations: Lesson 1'
        : (rec?['title'] ?? stateManager.currentLesson.title);
    final String reason = isNewLearner
        ? "Welcome to LearnIQ! Complete your first lesson so LearnIQ can understand how you learn."
        : (rec?['reason'] ?? "Continue your sequential progress through Python.");
    final int estTime = isNewLearner ? 3 : (rec?['estimated_time_minutes'] ?? 3);
    final String urgency = isNewLearner ? '🟢 NEXT STEP' : (rec?['urgency_tag'] ?? '🟢 CONTINUE');
    final Color cardColor = isNewLearner
        ? AppColors.duolingoGreen
        : ((rec?['urgency_tag']?.toString().contains('CRITICAL') ?? false)
            ? AppColors.misconceptionRed
            : AppColors.iqooCyan);

    final bool isTargetedFix = !isNewLearner && rec?['recommended_action'] == 'targeted_review';
    final String buttonLabel = isNewLearner
        ? 'START LESSON'
        : (isTargetedFix ? 'START 3-MIN FIX' : 'CONTINUE LESSON');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.15),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isNewLearner ? Icons.flag : Icons.gps_fixed, color: cardColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isNewLearner ? 'YOUR NEXT STEP' : 'AI NEXT BEST ACTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: cardColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  urgency,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '🎯 $title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 15, color: AppColors.iqooCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      children: [
                        const TextSpan(
                          text: 'Why? ',
                          style: TextStyle(color: AppColors.iqooCyan, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: reason),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$estTime min',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (isNewLearner) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => FirstLessonScreen(stateManager: stateManager),
                      ),
                    );
                  } else if (isTargetedFix) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => LessonEngineScreen(
                          concept: stateManager.currentLesson,
                          stateManager: stateManager,
                          isTargetedFixLaunch: true,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => LessonEngineScreen(
                          concept: stateManager.currentLesson,
                          stateManager: stateManager,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: isNewLearner ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    Text(
                      buttonLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(StudentState student) {
    final progress = student.dailyGoalMinutes > 0 ? (student.dailyProgressMinutes / student.dailyGoalMinutes) : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TODAY\'S GOAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${student.dailyProgressMinutes} / ${student.dailyGoalMinutes} min',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.iqooCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.iqooCyan),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            student.dailyProgressMinutes == 0
                ? '0 of ${student.dailyGoalMinutes} min completed. Start your first lesson to build your daily streak!'
                : (student.dailyProgressMinutes >= student.dailyGoalMinutes
                    ? 'Daily goal reached! Great job protecting your streak.'
                    : '${student.dailyGoalMinutes - student.dailyProgressMinutes} minutes remaining to reach today\'s goal!'),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTwinSummary(BuildContext context, StudentState student, bool isNewLearner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('🧠', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'AI LEARNING TWIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onTabChange(4),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  'VIEW TWIN →',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.iqooCyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!student.hasLearningEvidence || student.concepts.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Not enough learning data yet.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete your first lesson so LearnIQ can understand how you learn.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...student.concepts.entries.map((entry) {
              final name = entry.key;
              final data = entry.value;
              Color color = AppColors.duolingoGreen;
              String status = 'STABLE';
              if (data.status == TopicStatus.weak) {
                color = AppColors.misconceptionRed;
                status = 'WEAK';
              } else if (data.status == TopicStatus.practicing) {
                color = AppColors.xpAmber;
                status = 'PRACTICING';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildConceptBar(name[0].toUpperCase() + name.substring(1), data.mastery, color, status),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildConceptBar(String name, double mastery, Color color, String status) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: mastery,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${(mastery * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'iQOO SMART LAB & PRACTICE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Scan Code',
                subtitle: 'Camera OCR',
                icon: Icons.document_scanner,
                color: AppColors.iqooCyan,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const CodeScannerDialog(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Explain It',
                subtitle: 'Mic Teach-Back',
                icon: Icons.mic,
                color: AppColors.purpleAccent,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => TeachBackSheet(stateManager: stateManager),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Debug Arena',
                subtitle: 'Fix Broken Code',
                icon: Icons.pest_control,
                color: AppColors.xpAmber,
                onTap: () => onTabChange(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Ask LearnIQ',
                subtitle: 'AI Study Companion',
                icon: Icons.psychology_outlined,
                color: AppColors.iqooCyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AskLearnIQScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Weak Areas',
                subtitle: 'AI Cognitive Radar',
                icon: Icons.psychology,
                color: AppColors.misconceptionRed,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => WeakAreasScreen(stateManager: stateManager),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
