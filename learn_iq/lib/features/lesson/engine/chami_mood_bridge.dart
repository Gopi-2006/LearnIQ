import 'package:flutter/material.dart';
import '../../../core/models/story_curriculum_models.dart';
import '../../../core/theme/app_theme.dart';

/// Dynamic animated mascot and cognitive persona bridge for LearnIQ.
/// Displays Chami's live mood, breathing animation, speech bubble, and soft-pause alerts.
class ChamiMoodBridge extends StatefulWidget {
  final ChamiEmotion emotion;
  final String speechText;
  final String? subtitle;
  final bool isSoftPause;
  final VoidCallback? onDismissSoftPause;
  final bool isCompact;

  const ChamiMoodBridge({
    super.key,
    required this.emotion,
    required this.speechText,
    this.subtitle,
    this.isSoftPause = false,
    this.onDismissSoftPause,
    this.isCompact = false,
  });

  @override
  State<ChamiMoodBridge> createState() => _ChamiMoodBridgeState();
}

class _ChamiMoodBridgeState extends State<ChamiMoodBridge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getEmotionColor(ChamiEmotion emotion) {
    if (widget.isSoftPause) return const Color(0xFFFF9100);
    switch (emotion) {
      case ChamiEmotion.alert:
        return AppColors.misconceptionRed;
      case ChamiEmotion.thinking:
        return AppColors.iqooCyan;
      case ChamiEmotion.excited:
        return AppColors.duolingoGreen;
      case ChamiEmotion.celebrating:
        return AppColors.xpAmber;
      case ChamiEmotion.guiding:
        return const Color(0xFFB388FF);
    }
  }

  String _getEmotionEmoji(ChamiEmotion emotion) {
    if (widget.isSoftPause) return '🛡️';
    switch (emotion) {
      case ChamiEmotion.alert:
        return '😱';
      case ChamiEmotion.thinking:
        return '🤔';
      case ChamiEmotion.excited:
        return '⚡';
      case ChamiEmotion.celebrating:
        return '🎉';
      case ChamiEmotion.guiding:
        return '💡';
    }
  }

  String _getEmotionLabel(ChamiEmotion emotion) {
    if (widget.isSoftPause) return 'COGNITIVE SAFETY NET';
    switch (emotion) {
      case ChamiEmotion.alert:
        return 'SYNTAX SCANNER ALERT';
      case ChamiEmotion.thinking:
        return 'ANALYZING THOUGHT PATH';
      case ChamiEmotion.excited:
        return 'EUREKA MOMENT';
      case ChamiEmotion.celebrating:
        return 'MISSION ACCOMPLISHED';
      case ChamiEmotion.guiding:
        return 'CHAMI LIVE MENTOR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEmotionColor(widget.emotion);
    final emoji = _getEmotionEmoji(widget.emotion);
    final label = _getEmotionLabel(widget.emotion);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.all(widget.isCompact ? 10 : 14),
          decoration: BoxDecoration(
            color: widget.isSoftPause
                ? const Color(0xFF221708)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: widget.isSoftPause ? 0.9 : _glowAnimation.value),
              width: widget.isSoftPause ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: widget.isSoftPause ? 0.25 : 0.12),
                blurRadius: widget.isSoftPause ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isSoftPause) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9100).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFF9100), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, size: 12, color: Color(0xFFFF9100)),
                          SizedBox(width: 4),
                          Text(
                            'CHAMI SHADOW CODE • SOFT PAUSE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF9100),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (widget.onDismissSoftPause != null)
                      GestureDetector(
                        onTap: widget.onDismissSoftPause,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Mascot Avatar
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: widget.isCompact ? 38 : 46,
                      height: widget.isCompact ? 38 : 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.35),
                            color.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text('🦎', style: TextStyle(fontSize: 22)),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Text(emoji, style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
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
                              'Chami',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.speechText,
                          style: TextStyle(
                            fontSize: widget.isCompact ? 12.5 : 13.5,
                            height: 1.35,
                            color: AppColors.textPrimary,
                            fontWeight: widget.isSoftPause ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
