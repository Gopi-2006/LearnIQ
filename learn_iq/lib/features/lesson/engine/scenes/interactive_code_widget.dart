import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/story_curriculum_models.dart';
import '../../../../core/theme/app_theme.dart';

class InteractiveCodeWidget extends StatefulWidget {
  final StorySceneItem scene;
  final String? selectedOption;
  final List<String> orderedBlocks;
  final ValueChanged<String> onOptionSelected;
  final ValueChanged<List<String>> onOrderChanged;

  const InteractiveCodeWidget({
    super.key,
    required this.scene,
    this.selectedOption,
    required this.orderedBlocks,
    required this.onOptionSelected,
    required this.onOrderChanged,
  });

  @override
  State<InteractiveCodeWidget> createState() => _InteractiveCodeWidgetState();
}

class _InteractiveCodeWidgetState extends State<InteractiveCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Prompt
        if (widget.scene.questionPrompt != null) ...[
          Text(
            widget.scene.questionPrompt!,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Code Snippet Card
        if (widget.scene.codeSnippet != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.scene.codeSnippet!,
              style: GoogleFonts.firaCode(
                fontSize: 13.5,
                height: 1.45,
                color: const Color(0xFF58A6FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Options List (Multiple Choice or Output Prediction)
        if (widget.scene.options != null && widget.scene.options!.isNotEmpty)
          ...widget.scene.options!.map((option) {
            final isSelected = widget.selectedOption == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => widget.onOptionSelected(option),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.iqooCyan.withValues(alpha: 0.15)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.iqooCyan : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.iqooCyan : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.iqooCyan : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        // Reorderable Code Blocks (if applicable)
        if (widget.scene.codeBlocks != null && widget.scene.codeBlocks!.isNotEmpty) ...[
          const Text(
            'DRAG AND REORDER TO ASSEMBLE CODE:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              final list = List<String>.from(widget.orderedBlocks);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              widget.onOrderChanged(list);
            },
            children: [
              for (int i = 0; i < widget.orderedBlocks.length; i++)
                Container(
                  key: ValueKey('block_$i'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_handle, color: AppColors.textMuted, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        widget.orderedBlocks[i],
                        style: GoogleFonts.firaCode(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
