import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/story_curriculum_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../chami_mood_bridge.dart';

/// Bug Hunter Widget: Interactive line-by-line syntax & error recognition game.
/// Features cyber radar scanning, line-tap diagnostics, quick-fix patches, and virtual console output.
class BugHunterWidget extends StatefulWidget {
  final BugHunterProblemData problem;
  final ValueChanged<bool> onCompleted;

  const BugHunterWidget({
    super.key,
    required this.problem,
    required this.onCompleted,
  });

  @override
  State<BugHunterWidget> createState() => _BugHunterWidgetState();
}

class _BugHunterWidgetState extends State<BugHunterWidget>
    with SingleTickerProviderStateMixin {
  // Scanner state
  int? _selectedLineNumber;
  BugHunterFixOption? _selectedFix;
  bool _isBugLocated = false;
  bool _isSuccess = false;
  String? _terminalOutput;

  // Chami Persona state
  ChamiEmotion _chamiEmotion = ChamiEmotion.guiding;
  String _chamiDialogue = '';

  // Radar animation controller
  late AnimationController _radarController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _chamiDialogue =
        'Bug Hunter online! Tap the line that you suspect is causing the runtime exception.';
    _terminalOutput = widget.problem.brokenErrorOutput;

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _inspectLine(BugHunterLine line) {
    if (_isSuccess) return;

    setState(() {
      _selectedLineNumber = line.lineNumber;
      _selectedFix = null;

      if (line.isBuggy) {
        _isBugLocated = true;
        _chamiEmotion = ChamiEmotion.alert;
        _chamiDialogue =
            '🎯 Bullseye! Line ${line.lineNumber} is where the breakdown occurs. ${widget.problem.bugExplanation} Now choose the optimal patch!';
      } else {
        _isBugLocated = false;
        _chamiEmotion = ChamiEmotion.thinking;
        _chamiDialogue = line.cleanInspectionHint ??
            'Line ${line.lineNumber} passes static inspection. Look closely at variables, indexes, or return statements!';
      }
    });
  }

  void _selectFix(BugHunterFixOption fix) {
    setState(() {
      _selectedFix = fix;
      _chamiEmotion = ChamiEmotion.guiding;
      _chamiDialogue = 'Patch selected: "${fix.label}". Run diagnostics to test the patched script in the sandbox!';
    });
  }

  void _deployPatch() {
    if (_selectedFix == null) return;

    if (_selectedFix!.isCorrect) {
      setState(() {
        _isSuccess = true;
        _terminalOutput = widget.problem.expectedOutput;
        _chamiEmotion = ChamiEmotion.celebrating;
        _chamiDialogue =
            '🎉 Bug squashed! ${_selectedFix!.feedback} Code compiled and executed with zero errors.';
      });
      widget.onCompleted(true);
    } else {
      setState(() {
        _isSuccess = false;
        _chamiEmotion = ChamiEmotion.alert;
        _chamiDialogue =
            '⚠️ Patch rejected: ${_selectedFix!.feedback} Try choosing another fix.';
        _terminalOutput = 'Error: Patch failed automated test harness.\n${_selectedFix!.feedback}';
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _selectedLineNumber = null;
      _selectedFix = null;
      _isBugLocated = false;
      _isSuccess = false;
      _terminalOutput = widget.problem.brokenErrorOutput;
      _chamiEmotion = ChamiEmotion.guiding;
      _chamiDialogue =
          'Scanner reset. Tap any line in the code block to inspect for errors.';
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
            // Header briefing
            _buildProblemHeader(),

            const SizedBox(height: 12),

            // Live Chami Persona Bridge
            ChamiMoodBridge(
              emotion: _chamiEmotion,
              speechText: _chamiDialogue,
            ),

            const SizedBox(height: 16),

            // IDE Code Viewport with Line Tap Scanner
            _buildCodeInspectionViewport(),

            const SizedBox(height: 16),

            // Quick-Fix Patching Drawer (if buggy line is selected)
            if (_isBugLocated) _buildQuickFixDrawer(),

            const SizedBox(height: 16),

            // Virtual Execution Terminal
            _buildTerminalOutput(),

            const SizedBox(height: 16),

            // Action Button
            _buildBottomActionBar(),
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
            AppColors.misconceptionRed.withValues(alpha: 0.15),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.misconceptionRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pest_control, size: 12, color: AppColors.misconceptionRed),
                    SizedBox(width: 4),
                    Text(
                      'BUG HUNTER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.misconceptionRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.iqooCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.problem.concept.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.iqooCyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                      '+40 XP',
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
            widget.problem.scenario,
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

  Widget _buildCodeInspectionViewport() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        final double glowAlpha = 0.3 + (_scanAnimation.value * 0.4);
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isSuccess
                  ? AppColors.duolingoGreen
                  : (_isBugLocated
                      ? AppColors.misconceptionRed.withValues(alpha: glowAlpha)
                      : AppColors.border),
              width: _isSuccess || _isBugLocated ? 2 : 1,
            ),
            boxShadow: _isBugLocated
                ? [
                    BoxShadow(
                      color: AppColors.misconceptionRed.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IDE Window Chrome
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
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'syntax_inspection.py (Tap a line to scan)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedLineNumber != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _resetScanner,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.iqooCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Code lines
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: widget.problem.lines.map((line) {
                final isSelected = _selectedLineNumber == line.lineNumber;
                final isBug = line.isBuggy;
                final isPatchedLine = isBug && _isSuccess;

                Color lineBackground = Colors.transparent;
                if (isSelected) {
                  lineBackground = isBug
                      ? AppColors.misconceptionRed.withValues(alpha: 0.18)
                      : AppColors.iqooCyan.withValues(alpha: 0.12);
                } else if (isPatchedLine) {
                  lineBackground = AppColors.duolingoGreen.withValues(alpha: 0.15);
                }

                return InkWell(
                  onTap: () => _inspectLine(line),
                  child: Container(
                    color: lineBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Line Number
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${line.lineNumber}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: isSelected ? AppColors.iqooCyan : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),

                        // Radar / Status Icon
                        SizedBox(
                          width: 24,
                          child: isSelected
                              ? Icon(
                                  isBug ? Icons.pest_control : Icons.verified_user,
                                  size: 16,
                                  color: isBug ? AppColors.misconceptionRed : AppColors.iqooCyan,
                                )
                              : (isPatchedLine
                                  ? const Icon(Icons.check_circle, size: 16, color: AppColors.duolingoGreen)
                                  : const Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted)),
                        ),
                        const SizedBox(width: 8),

                        // Line Code Text
                        Expanded(
                          child: Text(
                            isPatchedLine && _selectedFix != null
                                ? _selectedFix!.fixedCode
                                : line.text,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: isPatchedLine
                                  ? AppColors.duolingoGreen
                                  : (isSelected && isBug
                                      ? AppColors.misconceptionRed
                                      : AppColors.textPrimary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),

                        // Target Indicator Badge
                        if (isSelected && isBug)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.misconceptionRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BUG FOUND',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFixDrawer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.build_circle, size: 18, color: AppColors.xpAmber),
              SizedBox(width: 8),
              Text(
                'TACTICAL QUICK-FIX OPTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.xpAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select the patch that resolves the issue cleanly:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Column(
            children: widget.problem.fixOptions.map((opt) {
              final isChosen = _selectedFix?.id == opt.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _selectFix(opt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isChosen
                          ? AppColors.iqooCyan.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isChosen ? AppColors.iqooCyan : AppColors.border,
                        width: isChosen ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChosen ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: isChosen ? AppColors.iqooCyan : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.fixedCode,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: AppColors.iqooCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalOutput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal, size: 14, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text(
                'VIRTUAL SANDBOX TERMINAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _terminalOutput ?? 'Ready for test execution...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: _isSuccess
                  ? AppColors.duolingoGreen
                  : AppColors.misconceptionRed,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isSuccess
            ? () => widget.onCompleted(true)
            : (_isBugLocated && _selectedFix != null ? _deployPatch : null),
        icon: Icon(
          _isSuccess ? Icons.check_circle : Icons.healing,
          size: 20,
        ),
        label: Text(
          _isSuccess
              ? 'BUG RESOLVED • CONTINUE'
              : (_isBugLocated ? 'DEPLOY PATCH & EXECUTE' : 'TAP BUGGY LINE FIRST'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSuccess
              ? AppColors.duolingoGreen
              : (_isBugLocated ? AppColors.iqooCyan : AppColors.card),
          foregroundColor: _isBugLocated || _isSuccess ? Colors.black : AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }
}
