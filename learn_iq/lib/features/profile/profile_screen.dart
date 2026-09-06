import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final LearningStateManager stateManager;

  const ProfileScreen({super.key, required this.stateManager});

  @override
  Widget build(BuildContext context) {
    final student = stateManager.student;
    final achievements = stateManager.achievements;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'PROFILE & LEARNING TWIN',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. User Header & Level
            _buildUserHeader(student),
            const SizedBox(height: 16),

            // 1B. HACKATHON JUDGE DEMO SWITCHER
            _buildDemoSwitcherCard(context),
            const SizedBox(height: 16),

            // 2. Level Progression Card
            _buildLevelProgressCard(student),
            const SizedBox(height: 16),

            // 3. AI Learning Twin Deep Dive
            _buildLearningTwinSection(student),
            const SizedBox(height: 16),

            // 4. Misconceptions Timeline
            _buildMisconceptionsCard(student),
            const SizedBox(height: 16),

            // 5. Achievements Shelf
            _buildAchievementsSection(achievements),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(StudentState student) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.iqooCyan.withValues(alpha: 0.2),
                child: const Text(
                  '👨‍💻',
                  style: TextStyle(fontSize: 34),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.duolingoGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const Text(
                  '@gopi_codes • iQOO 13 Flagship',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniBadge('🔥 ${student.streak} Streak', AppColors.streakFlame),
                    const SizedBox(width: 8),
                    _buildMiniBadge('💎 ${student.gems} Gems', AppColors.gemBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSwitcherCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: AppColors.iqooCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'JUDGE DEMO MODE CONTROLLER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.iqooCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Instantly toggle between a fresh user onboarding walkthrough and the advanced Level 3 Functions misconception demo.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await stateManager.resetToNewUser();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reset to brand-new user! Launching onboarding...'),
                          backgroundColor: AppColors.duolingoGreen,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('RESET (NEW USER)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await stateManager.switchToReturningUserDemo();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switched to Level 3 Demo with Functions Misconception!'),
                          backgroundColor: AppColors.iqooCyan,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.flash_on, size: 16),
                  label: const Text('LEVEL 3 DEMO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iqooCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildLevelProgressCard(StudentState student) {
    const int nextLevelXp = 1500;
    const int currentBaseXp = 1000;
    final double levelProgress = (student.xp - currentBaseXp) / (nextLevelXp - currentBaseXp);

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
                children: [
                  const Icon(Icons.military_tech, color: AppColors.xpAmber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'LEVEL ${student.level} — ${student.levelTitle.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.xpAmber,
                    ),
                  ),
                ],
              ),
              Text(
                '${student.xp} / $nextLevelXp XP',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: levelProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpAmber),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Next Rank: Level 4 — Bug Hunter at 1,500 XP',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTwinSection(StudentState student) {
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
            children: const [
              Text('🧠', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'AI LEARNING TWIN MODEL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.iqooCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your phone continuously updates this cognitive twin after every exercise, mistake, and teach-back.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // High-level twin metrics
          Row(
            children: [
              _buildTwinMetricBox('Understanding', '78%', AppColors.duolingoGreen),
              const SizedBox(width: 8),
              _buildTwinMetricBox('Retention', '71%', AppColors.xpAmber),
              const SizedBox(width: 8),
              _buildTwinMetricBox('Application', '63%', AppColors.iqooCyan),
              const SizedBox(width: 8),
              _buildTwinMetricBox('Consistency', '84%', AppColors.purpleAccent),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'CONCEPT STABILITY BREAKDOWN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          ...student.concepts.entries.map((entry) {
            final name = entry.key;
            final data = entry.value;
            final pct = (data.mastery * 100).toInt();
            Color color = AppColors.duolingoGreen;
            String status = 'Stable';

            if (data.mastery < 0.50) {
              color = AppColors.misconceptionRed;
              status = 'Fragile';
            } else if (data.mastery < 0.80) {
              color = AppColors.xpAmber;
              status = 'Improving';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: data.mastery,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(width: 8),
                  Text(status, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTwinMetricBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisconceptionsCard(StudentState student) {
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
            children: const [
              Icon(Icons.psychology_alt, color: AppColors.misconceptionRed, size: 20),
              SizedBox(width: 8),
              Text(
                'MISCONCEPTIONS TRACKER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.misconceptionRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Misconceptions
          if (student.activeMisconceptions.isNotEmpty) ...[
            const Text(
              'ACTIVE (NEEDS ATTENTION):',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            ...student.activeMisconceptions.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.misconceptionRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: AppColors.misconceptionRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // Resolved Misconceptions
          const Text(
            'RESOLVED BY TARGETED REPAIRS:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          ...student.resolvedMisconceptions.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.duolingoGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.duolingoGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, color: AppColors.duolingoGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.duolingoGreen),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CODING ACHIEVEMENTS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final a = achievements[index];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: a.isUnlocked ? AppColors.xpAmber.withValues(alpha: 0.4) : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    a.icon,
                    color: a.isUnlocked ? AppColors.xpAmber : AppColors.textMuted,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          a.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: a.isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          a.description,
                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
