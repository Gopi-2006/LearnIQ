import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  final LearningStateManager stateManager;

  const PracticeScreen({super.key, required this.stateManager});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'PRACTICE LAB & ARENA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.iqooCyan,
          labelColor: AppColors.iqooCyan,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.pest_control, size: 20), text: 'Debug Arena'),
            Tab(icon: Icon(Icons.radar, size: 20), text: 'Review Radar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebugArenaTab(),
          _buildReviewRadarTab(),
        ],
      ),
    );
  }

  Widget _buildDebugArenaTab() {
    final problems = widget.stateManager.debugProblems;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final p = problems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                    child: Text(
                      p.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.xpAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${p.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.xpAmber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.misconceptionRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.errorType,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.misconceptionRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Broken Code Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1017),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  p.brokenCode,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: const Color(0xFFE6EDF3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.xpAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.hint,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showFixDialog(p);
                  },
                  icon: const Icon(Icons.build_circle, size: 18),
                  label: const Text('FIX THIS BUG IN SANDBOX'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iqooCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFixDialog(DebugProblem p) {
    showDialog(
      context: context,
      builder: (ctx) => _DebugFixDialog(
        problem: p,
        stateManager: widget.stateManager,
      ),
    );
  }

  Widget _buildReviewRadarTab() {
    final concepts = widget.stateManager.student.concepts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radar Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.misconceptionRed.withValues(alpha: 0.15),
                  AppColors.card,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.radar, color: AppColors.misconceptionRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI FORGETTING RADAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.misconceptionRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'LearnIQ detects which concepts are decaying before you fail an exam or code challenge.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppColors.misconceptionRed, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔴 Loops (42% retention) is likely your next weak concept.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'ESTIMATED CONCEPT RETENTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Concept Retention Cards
          ...concepts.entries.map((entry) {
            final name = entry.key;
            final data = entry.value;
            final int retPct = (data.retention * 100).toInt();
            Color statusColor = AppColors.duolingoGreen;
            String statusLabel = '🟢 STABLE';

            if (data.retention < 0.50) {
              statusColor = AppColors.misconceptionRed;
              statusLabel = '🔴 CRITICAL DECAY';
            } else if (data.retention < 0.75) {
              statusColor = AppColors.xpAmber;
              statusLabel = '🟡 FRAGILE';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusLabel,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.retention,
                            minHeight: 8,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$retPct%',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: statusColor),
                      ),
                      const Text('Retention', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Starting 3-minute spaced review for Loops & Lists...'),
                    backgroundColor: AppColors.iqooCyan,
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('START 3-MIN SMART REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.iqooCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugFixDialog extends StatefulWidget {
  final DebugProblem problem;
  final LearningStateManager stateManager;

  const _DebugFixDialog({
    required this.problem,
    required this.stateManager,
  });

  @override
  State<_DebugFixDialog> createState() => _DebugFixDialogState();
}

class _DebugFixDialogState extends State<_DebugFixDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.problem.expectedFix);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Fix: ${p.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter the corrected code line:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.stateManager.submitAnswer(
              exerciseId: p.id,
              concept: 'debug_arena',
              questionType: 'bug_fix',
              studentAnswer: _controller.text,
              expectedAnswer: p.expectedFix,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Bug Fixed! +${p.xpReward} XP earned.'),
                backgroundColor: AppColors.duolingoGreen,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.duolingoGreen,
            foregroundColor: Colors.black,
          ),
          child: const Text('SUBMIT FIX'),
        ),
      ],
    );
  }
}
