import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../lesson/lesson_runner_screen.dart';

class WeakAreasScreen extends StatelessWidget {
  final LearningStateManager stateManager;

  const WeakAreasScreen({super.key, required this.stateManager});

  @override
  Widget build(BuildContext context) {
    final student = stateManager.student;
    final weakTopics = student.weakTopics;
    final evaluatedConcepts = student.concepts.values
        .where((c) => c.hasEnoughEvidence)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'MY WEAK AREAS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: (!student.hasLearningEvidence || weakTopics.isEmpty)
            ? _buildCleanZeroState(context)
            : _buildEvidenceWeakAreasView(context, weakTopics, evaluatedConcepts),
      ),
    );
  }

  Widget _buildCleanZeroState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.duolingoGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 48,
                  color: AppColors.duolingoGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No weak areas yet.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete a few lessons and practice questions first.\n\nLearnIQ will identify your actual weak concepts and misconceptions from your real performance.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text(
                    'GO TO LESSON 1',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceWeakAreasView(
    BuildContext context,
    List<MapEntry<String, ConceptMastery>> weakTopics,
    List<ConceptMastery> evaluatedConcepts,
  ) {
    final weakestEntry = weakTopics.first;
    final String weakestName = weakestEntry.key;
    final ConceptMastery weakest = weakestEntry.value;
    final int weakestPct = (weakest.mastery * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Cognitive Diagnostic Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A141A), Color(0xFF161B22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.misconceptionRed.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                      color: AppColors.misconceptionRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.radar, color: AppColors.misconceptionRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'EVIDENCE-BASED DIAGNOSTIC',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.misconceptionRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildDiagnosticRow('Weakest Topic:', '${weakestName.toUpperCase()} ($weakestPct% Mastery)'),
              _buildDiagnosticRow('Attempts Recorded:', '${weakest.totalAttempts} practice interactions'),
              _buildDiagnosticRow('Diagnostic Status:', 'Weak (Accuracy < 50% with confirmed evidence)'),
              _buildDiagnosticRow('Recommended Action:', '3-minute targeted remediation practice'),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text(
                    'START 3-MIN TARGETED REPAIR DRILL',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.misconceptionRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonRunnerScreen(
                          stateManager: stateManager,
                          isTargetedFixLaunch: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Topic-by-topic breakdown
        const Text(
          'CONFIRMED WEAK CONCEPTS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        ...weakTopics.map((entry) {
          final String conceptName = entry.key;
          final ConceptMastery concept = entry.value;
          final double score = concept.mastery;
          final int pct = (score * 100).toInt();

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.misconceptionRed.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conceptName.toUpperCase(),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.misconceptionRed.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'WEAK',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.misconceptionRed),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.misconceptionRed),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF0F141C),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.misconceptionRed),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiagnosticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
