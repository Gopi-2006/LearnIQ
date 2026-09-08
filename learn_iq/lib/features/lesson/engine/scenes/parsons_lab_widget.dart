import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/story_curriculum_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../chami_mood_bridge.dart';

class PlacedParsonsBlock {
  final ParsonsBlock block;
  int indentLevel; // 0, 1 (4 spaces), 2 (8 spaces)

  PlacedParsonsBlock({
    required this.block,
    this.indentLevel = 0,
  });
}

/// Parsons Lab Widget: Kinesthetic drag-and-drop structural & scope puzzle.
/// Features multi-level indentation control and Chami's real-time shadow code diagnostics.
class ParsonsLabWidget extends StatefulWidget {
  final ParsonsProblemData problem;
  final ValueChanged<bool> onCompleted;

  const ParsonsLabWidget({
    super.key,
    required this.problem,
    required this.onCompleted,
  });

  @override
  State<ParsonsLabWidget> createState() => _ParsonsLabWidgetState();
}

class _ParsonsLabWidgetState extends State<ParsonsLabWidget> {
  // Assembly state
  late List<ParsonsBlock> _availablePool;
  final List<PlacedParsonsBlock> _assembledCode = [];

  // Verification & Feedback state
  bool _isChecked = false;
  bool _isSuccess = false;
  String? _diagnosticFeedback;

  // Chami Persona state
  ChamiEmotion _chamiEmotion = ChamiEmotion.guiding;
  String _chamiDialogue = '';
  bool _isSoftPause = false;

  // Shadow Code Diagnostics: Rapid shuffle & hesitation tracking
  final List<DateTime> _rearrangementTimestamps = [];
  Timer? _hesitationTimer;
  int _hesitationSeconds = 0;

  @override
  void initState() {
    super.initState();
    _availablePool = List.from(widget.problem.blocks)..shuffle();
    _chamiDialogue =
        'Welcome to the Parsons Lab! Drag or tap blocks in order, and adjust indentation for inner scope blocks.';
    _startHesitationTimer();
  }

  @override
  void dispose() {
    _hesitationTimer?.cancel();
    super.dispose();
  }

  void _startHesitationTimer() {
    _hesitationTimer?.cancel();
    _hesitationSeconds = 0;
    _hesitationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _hesitationSeconds++;

      // If user hasn't made a move for 12 seconds and still hasn't completed
      if (_hesitationSeconds >= 12 && !_isSuccess && !_isSoftPause && _assembledCode.length < widget.problem.blocks.length) {
        _triggerSoftPause(
          'Stuck? Look at the keywords. Remember that control blocks like "def" or "for" must come first, followed by indented lines!',
        );
      }
    });
  }

  void _recordInteraction() {
    _hesitationSeconds = 0;
    final now = DateTime.now();
    _rearrangementTimestamps.add(now);

    // Filter to last 10 seconds
    _rearrangementTimestamps.removeWhere(
      (ts) => now.difference(ts).inSeconds > 10,
    );

    // Chami's Shadow Code Diagnostic: 4+ rearrangements in 10 seconds
    if (_rearrangementTimestamps.length >= 4 && !_isSoftPause && !_isSuccess) {
      _triggerSoftPause(
        widget.problem.softPauseHint.isNotEmpty
            ? widget.problem.softPauseHint
            : 'Frequent rearrangements detected! Python executes sequentially from top to bottom. Let\'s place the definition block first.',
      );
    }
  }

  void _triggerSoftPause(String reason) {
    setState(() {
      _isSoftPause = true;
      _chamiEmotion = ChamiEmotion.guiding;
      _chamiDialogue = reason;
    });
  }

  void _dismissSoftPause() {
    setState(() {
      _isSoftPause = false;
      _chamiDialogue = 'Keep going! Assemble the remaining blocks.';
    });
  }

  void _addBlockToWorkspace(ParsonsBlock block) {
    _recordInteraction();
    setState(() {
      _availablePool.removeWhere((b) => b.id == block.id);
      _assembledCode.add(PlacedParsonsBlock(
        block: block,
        indentLevel: 0,
      ));
      _isChecked = false;
      _diagnosticFeedback = null;
      _chamiEmotion = ChamiEmotion.thinking;
      _chamiDialogue = 'Block added! Need to indent it? Use the indent buttons (+4).';
    });
  }

  void _removeBlockFromWorkspace(int index) {
    _recordInteraction();
    setState(() {
      final removed = _assembledCode.removeAt(index);
      _availablePool.add(removed.block);
      _isChecked = false;
      _diagnosticFeedback = null;
    });
  }

  void _cycleIndent(int index) {
    _recordInteraction();
    setState(() {
      final item = _assembledCode[index];
      item.indentLevel = (item.indentLevel + 1) % 3; // 0 -> 1 -> 2 -> 0
      _isChecked = false;
      _diagnosticFeedback = null;
      _chamiEmotion = ChamiEmotion.thinking;
      _chamiDialogue =
          item.indentLevel > 0 ? 'Indented to +${item.indentLevel * 4} spaces (nested scope)!' : 'Reset to top-level indentation (0 spaces).';
    });
  }

  void _checkSolution() {
    _hesitationTimer?.cancel();

    if (_assembledCode.isEmpty) {
      setState(() {
        _chamiEmotion = ChamiEmotion.alert;
        _chamiDialogue = 'Workspace is empty! Tap blocks from the pool below to assemble your program.';
        _isChecked = true;
        _isSuccess = false;
        _diagnosticFeedback = 'No code assembled yet. Tap or drag blocks into the workspace.';
      });
      return;
    }

    if (_assembledCode.length < widget.problem.correctSequenceIds.length) {
      setState(() {
        _chamiEmotion = ChamiEmotion.alert;
        _chamiDialogue = 'You haven\'t placed all necessary code blocks yet. Place all blocks to complete the script.';
        _isChecked = true;
        _isSuccess = false;
        _diagnosticFeedback = 'Incomplete script: ${_assembledCode.length}/${widget.problem.correctSequenceIds.length} blocks placed.';
      });
      return;
    }

    bool sequenceCorrect = true;
    bool indentCorrect = true;
    String? failureNote;

    for (int i = 0; i < widget.problem.correctSequenceIds.length; i++) {
      final targetId = widget.problem.correctSequenceIds[i];
      final placed = _assembledCode[i];

      if (placed.block.id != targetId) {
        sequenceCorrect = false;
        failureNote = 'Order issue around line ${i + 1}. Check which statement must execute prior to this one.';
        break;
      }

      if (placed.indentLevel != placed.block.correctIndentLevel) {
        indentCorrect = false;
        final expectedSpaces = placed.block.correctIndentLevel * 4;
        failureNote = 'Indentation discrepancy on line ${i + 1}. Expected $expectedSpaces spaces of indentation.';
        break;
      }
    }

    if (sequenceCorrect && indentCorrect) {
      setState(() {
        _isChecked = true;
        _isSuccess = true;
        _isSoftPause = false;
        _chamiEmotion = ChamiEmotion.celebrating;
        _chamiDialogue = 'Brilliant execution! Scope and order logic are spot-on! 🎉';
        _diagnosticFeedback = 'Code executed successfully with zero runtime errors!';
      });
      widget.onCompleted(true);
    } else {
      setState(() {
        _isChecked = true;
        _isSuccess = false;
        _chamiEmotion = ChamiEmotion.alert;
        _chamiDialogue = failureNote ?? 'Not quite right yet. Review the block order and indentation depth.';
        _diagnosticFeedback = failureNote;
      });
    }
  }

  void _resetWorkspace() {
    setState(() {
      _availablePool = List.from(widget.problem.blocks)..shuffle();
      _assembledCode.clear();
      _isChecked = false;
      _isSuccess = false;
      _diagnosticFeedback = null;
      _chamiEmotion = ChamiEmotion.guiding;
      _chamiDialogue = 'Workspace reset. Let\'s build it step by step!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            _buildProblemHeader(),

            const SizedBox(height: 12),

            // Live Chami Persona Bridge & Diagnostics
            ChamiMoodBridge(
              emotion: _chamiEmotion,
              speechText: _chamiDialogue,
              isSoftPause: _isSoftPause,
              onDismissSoftPause: _dismissSoftPause,
            ),

            const SizedBox(height: 16),

            // Target Workspace (The Active Code Area)
            _buildTargetWorkspace(),

            const SizedBox(height: 16),

            // Available Blocks Drawer / Pool
            _buildAvailableBlocksPool(),

            const SizedBox(height: 16),

            // Diagnostic feedback (if checked)
            if (_diagnosticFeedback != null) _buildDiagnosticCard(),

            const SizedBox(height: 16),

            // Bottom Action Bar
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.iqooCyan.withValues(alpha: 0.15),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.iqooCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.extension, size: 12, color: AppColors.iqooCyan),
                    SizedBox(width: 4),
                    Text(
                      'PARSONS LAB',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.iqooCyan,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purpleAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.problem.concept.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purpleAccent,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.xpAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, size: 12, color: AppColors.xpAmber),
                    SizedBox(width: 2),
                    Text(
                      '+35 XP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.xpAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.problem.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.problem.objective,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWorkspace() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSuccess
              ? AppColors.duolingoGreen
              : (_isChecked ? AppColors.misconceptionRed : AppColors.border),
          width: _isSuccess ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workspace Window Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'active_script.py (Drag to order, tap tab to indent)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_assembledCode.isNotEmpty)
                  GestureDetector(
                    onTap: _resetWorkspace,
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.misconceptionRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Reorderable Assembled Blocks List
          if (_assembledCode.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.touch_app, size: 36, color: AppColors.iqooCyan.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  const Text(
                    'Workspace is empty',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap blocks in the pool below to add them to your program.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assembledCode.length,
              onReorderItem: (oldIndex, newIndex) {
                _recordInteraction();
                setState(() {
                  final item = _assembledCode.removeAt(oldIndex);
                  _assembledCode.insert(newIndex, item);
                  _isChecked = false;
                  _diagnosticFeedback = null;
                });
              },
              itemBuilder: (context, index) {
                final item = _assembledCode[index];
                return _buildPlacedBlockItem(item, index, key: ValueKey(item.block.id));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlacedBlockItem(PlacedParsonsBlock item, int index, {required Key key}) {
    final indentPadding = item.indentLevel * 24.0;

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.indentLevel > 0
              ? AppColors.purpleAccent.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Drag Handle
            const Icon(Icons.drag_indicator, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 4),

            // Line Number
            SizedBox(
              width: 22,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Indentation visual spacer
            if (indentPadding > 0)
              Container(
                width: indentPadding,
                height: 20,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.purpleAccent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ' · ' * item.indentLevel,
                    style: TextStyle(
                      color: AppColors.purpleAccent.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            // Code Content
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  item.block.text,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iqooCyan,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Compact Indent adjustment button
            InkWell(
              onTap: () => _cycleIndent(index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: item.indentLevel > 0
                      ? AppColors.purpleAccent.withValues(alpha: 0.3)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.indentLevel > 0
                        ? AppColors.purpleAccent
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_indent_increase, size: 12, color: AppColors.textPrimary),
                    const SizedBox(width: 2),
                    Text(
                      '${item.indentLevel * 4}s',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Compact Remove button
            InkWell(
              onTap: () => _removeBlockFromWorkspace(index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 15, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBlocksPool() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_mosaic, size: 16, color: AppColors.iqooCyan),
            const SizedBox(width: 6),
            const Text(
              'BLOCK POOL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${_availablePool.length} unplaced',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_availablePool.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'All blocks placed in program! Tap "Run & Verify" to test.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.duolingoGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availablePool.map((b) {
              return InkWell(
                onTap: () => _addBlockToWorkspace(b),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 14, color: AppColors.iqooCyan),
                      const SizedBox(width: 8),
                      Text(
                        b.text,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDiagnosticCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSuccess
            ? AppColors.duolingoGreen.withValues(alpha: 0.12)
            : AppColors.misconceptionRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSuccess ? AppColors.duolingoGreen : AppColors.misconceptionRed,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.bug_report,
            size: 18,
            color: _isSuccess ? AppColors.duolingoGreen : AppColors.misconceptionRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSuccess ? 'EXECUTION SUCCESSFUL' : 'SYNTAX & SCOPE NOTICE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _isSuccess ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _diagnosticFeedback!,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.3),
                ),
                if (_isSuccess && widget.problem.solutionExplanation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.problem.solutionExplanation,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _checkSolution,
        icon: Icon(
          _isSuccess ? Icons.arrow_forward : Icons.play_arrow,
          size: 20,
        ),
        label: Text(
          _isSuccess ? 'CONTINUE TO NEXT CHALLENGE' : 'RUN & VERIFY CODE',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSuccess ? AppColors.duolingoGreen : AppColors.iqooCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }
}
