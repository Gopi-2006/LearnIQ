import 'package:flutter/material.dart';
import '../../../core/models/story_curriculum_models.dart';
import '../../../core/theme/app_theme.dart';

class ChamiMascotWidget extends StatelessWidget {
  final ChamiSpeech speech;
  final bool isCompact;

  const ChamiMascotWidget({
    super.key,
    required this.speech,
    this.isCompact = false,
  });

  Color _getEmotionColor(ChamiEmotion emotion) {
    switch (emotion) {
      case ChamiEmotion.alert:
        return const Color(0xFFFF5252);
      case ChamiEmotion.thinking:
        return AppColors.iqooCyan;
      case ChamiEmotion.excited:
        return AppColors.duolingoGreen;
      case ChamiEmotion.celebrating:
        return const Color(0xFFFFD700);
      case ChamiEmotion.guiding:
        return const Color(0xFFB388FF);
    }
  }

  String _getEmotionEmoji(ChamiEmotion emotion) {
    switch (emotion) {
      case ChamiEmotion.alert:
        return '😱';
      case ChamiEmotion.thinking:
        return '🤔';
      case ChamiEmotion.excited:
        return '😄';
      case ChamiEmotion.celebrating:
        return '🎉';
      case ChamiEmotion.guiding:
        return '💡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor = _getEmotionColor(speech.emotion);
    final emotionEmoji = _getEmotionEmoji(speech.emotion);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emotionColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: emotionColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chami Mascot Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  emotionColor.withValues(alpha: 0.3),
                  emotionColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: emotionColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('🦎', style: TextStyle(fontSize: 22)),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Text(emotionEmoji, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Speech Bubble Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Chami the Chameleon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: emotionColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: emotionColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        speech.emotion.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: emotionColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  speech.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
