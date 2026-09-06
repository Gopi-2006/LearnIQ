import 'package:flutter/material.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';

class LeagueScreen extends StatelessWidget {
  final LearningStateManager stateManager;

  const LeagueScreen({super.key, required this.stateManager});

  @override
  Widget build(BuildContext context) {
    final users = stateManager.leagueUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'WEEKLY CODING LEAGUE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // League Tier Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF33260A),
                    AppColors.card,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.xpAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.xpAmber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🥇', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GOLD CODER LEAGUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.xpAmber,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Top 3 promote to Diamond League in 2d 14h! Keep fixing misconceptions.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Leaderboard List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                final isTop3 = index < 3;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: u.isCurrentUser
                        ? AppColors.iqooCyan.withValues(alpha: 0.12)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: u.isCurrentUser
                          ? AppColors.iqooCyan
                          : (isTop3 ? AppColors.xpAmber.withValues(alpha: 0.3) : AppColors.border),
                      width: u.isCurrentUser ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank Icon or Number
                      SizedBox(
                        width: 32,
                        child: Text(
                          index == 0
                              ? '🥇'
                              : (index == 1 ? '🥈' : (index == 2 ? '🥉' : '${index + 1}')),
                          style: TextStyle(
                            fontSize: isTop3 ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: isTop3 ? AppColors.xpAmber : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: u.avatarColor.withValues(alpha: 0.2),
                        child: Text(
                          u.name.substring(0, 1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: u.avatarColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: u.isCurrentUser ? AppColors.iqooCyan : AppColors.textPrimary,
                              ),
                            ),
                            if (u.isCurrentUser)
                              const Text(
                                'PROMOTION ZONE 🚀',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.duolingoGreen,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // XP Counter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${u.xp} XP',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
