import 'package:flutter/material.dart';

class DoubtInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final bool isLoading;
  final VoidCallback? onAddAttachment;
  final VoidCallback? onMicTap;

  const DoubtInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.isLoading = false,
    this.onAddAttachment,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171D27),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // [ + ] Action / Attachment Button
              IconButton(
                onPressed: onAddAttachment ?? () {},
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white54,
                  size: 22,
                ),
                tooltip: 'Attach or Explore Options',
                splashRadius: 20,
              ),

              // Expanding Text Composer
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSubmitted(),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Ask anything you're learning...",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),

              // Optional 🎤 Microphone button
              IconButton(
                onPressed: onMicTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice doubt search ready. Type or speak your doubt.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: Colors.white54,
                  size: 21,
                ),
                tooltip: 'Voice Input',
                splashRadius: 20,
              ),

              const SizedBox(width: 2),

              // [Send] Action Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withValues(alpha: isLoading ? 0.4 : 1.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: isLoading ? null : onSubmitted,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.black87,
                          size: 18,
                        ),
                  tooltip: 'Send Question',
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
