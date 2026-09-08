import 'package:flutter/material.dart';
import '../../../../core/services/local_adaptive_ai_engine.dart';
import '../../../../core/theme/app_theme.dart';
import '../chami_mood_bridge.dart';
import '../../../../core/models/story_curriculum_models.dart';
import '../../../../core/services/learning_state_manager.dart';

class ProveYouUnderstandDialog extends StatefulWidget {
  final String topicId;
  final String topicTitle;
  final ValueChanged<bool>? onCompleted;

  const ProveYouUnderstandDialog({
    super.key,
    required this.topicId,
    required this.topicTitle,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String topicId = 'feynman_active',
    required String conceptTitle,
    required LearningStateManager stateManager,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ProveYouUnderstandDialog(
        topicId: topicId,
        topicTitle: conceptTitle,
        onCompleted: (success) {
          if (success) {
            stateManager.addExperience(25);
          }
        },
      ),
    );
  }

  @override
  State<ProveYouUnderstandDialog> createState() => _ProveYouUnderstandDialogState();
}

class _ProveYouUnderstandDialogState extends State<ProveYouUnderstandDialog> {
  final TextEditingController _controller = TextEditingController();
  ProveUnderstandResult? _result;
  bool _isEvaluating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeUnderstanding() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isEvaluating = true;
    });

    // 100% Offline evaluation via LocalAdaptiveAiEngine
    final res = LocalAdaptiveAiEngine().evaluateProveUnderstand(
      topicId: widget.topicId,
      studentExplanation: text,
    );

    setState(() {
      _result = res;
      _isEvaluating = false;
    });

    if (res.isSatisfactory && widget.onCompleted != null) {
      widget.onCompleted!(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.purpleAccent, width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology, color: AppColors.purpleAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROVE YOU UNDERSTAND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.purpleAccent,
                        ),
                      ),
                      Text(
                        widget.topicTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Feynman Prompt
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feynman Principle: Explain this concept in your own words as if teaching a friend. No textbook jargon needed!',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input field
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g., In Python, when you call return it actually hands the result back in memory, whereas print just shows words on the screen...',
                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                filled: true,
                fillColor: const Color(0xFF0F141C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.purpleAccent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result feedback if evaluated
            if (_result != null) ...[
              ChamiMoodBridge(
                emotion: _result!.isSatisfactory ? ChamiEmotion.celebrating : ChamiEmotion.guiding,
                speechText: _result!.chamiCritique,
                isCompact: true,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ..._result!.identifiedConcepts.map(
                    (c) => Chip(
                      avatar: const Icon(Icons.check, size: 14, color: AppColors.duolingoGreen),
                      label: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                      backgroundColor: AppColors.duolingoGreen.withValues(alpha: 0.15),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  ..._result!.missingElements.map(
                    (m) => Chip(
                      avatar: const Icon(Icons.priority_high, size: 14, color: AppColors.xpAmber),
                      label: Text('Missing: $m', style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                      backgroundColor: AppColors.xpAmber.withValues(alpha: 0.15),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Submit / Continue Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isEvaluating ? null : _analyzeUnderstanding,
                icon: Icon(
                  _result?.isSatisfactory == true ? Icons.check_circle : Icons.auto_awesome,
                  size: 18,
                ),
                label: Text(
                  _result?.isSatisfactory == true ? 'UNDERSTANDING PROVEN (+30 XP)' : 'ANALYZE MY EXPLANATION',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _result?.isSatisfactory == true ? AppColors.duolingoGreen : AppColors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
