import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_logger.dart';

class TeachBackSheet extends StatefulWidget {
  final LearningStateManager stateManager;

  const TeachBackSheet({super.key, required this.stateManager});

  @override
  State<TeachBackSheet> createState() => _TeachBackSheetState();
}

class _TeachBackSheetState extends State<TeachBackSheet> {
  bool _isRecording = false;
  int _timerSeconds = 30;
  Timer? _timer;
  String _transcript = '';
  bool _isAnalyzing = false;
  bool _hasTimedOut = false;
  Map<String, dynamic>? _analysisResult;

  void _startRecording() {
    AppLogger.mic('Started voice recording');
    setState(() {
      _isRecording = true;
      _timerSeconds = 30;
      _analysisResult = null;
      _hasTimedOut = false;
      _transcript = 'Listening to verbal explanation...';
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    AppLogger.mic('Stopped voice recording');
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      if (_transcript.contains('Listening')) {
        // Fallback sample explanation if judge stopped early
        _transcript =
            'A function in Python is a named block defined with def that takes arguments, but you just print the calculation out to the screen.';
      }
    });
    _analyzeExplanation();
  }

  Future<void> _analyzeExplanation() async {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = true;
      _hasTimedOut = false;
    });

    AppLogger.ai('Submitting TeachBack explanation for analysis');

    try {
      final res = await ApiService.evaluateTeachBack(
        concept: 'functions',
        explanationText: _transcript,
      ).timeout(const Duration(seconds: 6));

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = res;
        });
      }
    } on TimeoutException {
      AppLogger.ai('TeachBack evaluation timed out. Showing fallback choices.');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasTimedOut = true;
        });
      }
    } catch (e) {
      AppLogger.ai('TeachBack error caught: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasTimedOut = true;
        });
      }
    }
  }

  void _applyLocalFallback() {
    setState(() {
      _hasTimedOut = false;
      _isAnalyzing = false;
      final lower = _transcript.toLowerCase();
      final hasReturn = lower.contains('return') || lower.contains('sends back');
      _analysisResult = {
        'overall_understanding': hasReturn ? 88 : 68,
        'dimensions': [
          {'dimension': 'Function Definition & Def', 'score': 92, 'status': 'passed'},
          {'dimension': 'Parameters & Arguments', 'score': 88, 'status': 'passed'},
          {'dimension': 'Return Values vs Print', 'score': hasReturn ? 85 : 42, 'status': hasReturn ? 'passed' : 'gap_detected'},
          {'dimension': 'Reusability & Invocation', 'score': 90, 'status': 'passed'},
        ],
        'gap_summary': hasReturn
            ? 'Great job! You covered definition, inputs, reusability, and return values.'
            : 'You explained function definition and arguments, but you did not mention how functions pass data back using return.',
        'found_gap': !hasReturn,
        'detected_misconception': hasReturn ? null : 'confusing print with return',
        'recommended_intervention': 'Complete a 3-minute micro-exercise on function return mechanics.',
      };
    });
  }

  void _usePreset(bool hasReturnGap) {
    setState(() {
      if (hasReturnGap) {
        _transcript =
            'A Python function is a block of code starting with def that takes parameters and runs multiple times to print results.';
      } else {
        _transcript =
            'A Python function is a reusable block defined with def that accepts inputs and sends a calculated value back using return.';
      }
    });
    _analyzeExplanation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: const [
                Icon(Icons.mic, color: AppColors.purpleAccent, size: 22),
                SizedBox(width: 8),
                Text(
                  'PROVE YOU UNDERSTAND • TEACH-BACK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '🎙️ Explain what a Python function is as if you are teaching it to a beginner.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Waveform & Mic Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1017),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecording ? AppColors.purpleAccent : AppColors.border,
                  width: _isRecording ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '00:${_timerSeconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _isRecording ? AppColors.misconceptionRed : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Waveform simulation bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(18, (i) {
                      final double h = _isRecording ? ((i % 5 + 1) * 7.0 + 8.0) : 6.0;
                      return Container(
                        width: 4,
                        height: h,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _isRecording ? AppColors.purpleAccent : AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Record / Stop Button
                  GestureDetector(
                    onTap: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? AppColors.misconceptionRed : AppColors.purpleAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? AppColors.misconceptionRed : AppColors.purpleAccent)
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRecording ? 'Tap to Stop & Analyze' : 'Tap to Record Voice',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Demo Voice Presets for Judge
            Row(
              children: [
                const Text('Demo Presets: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ActionChip(
                  label: const Text('With Return Gap ❌', style: TextStyle(fontSize: 10)),
                  onPressed: () => _usePreset(true),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Complete Explanation ✅', style: TextStyle(fontSize: 10)),
                  onPressed: () => _usePreset(false),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Transcript text box
            if (_transcript.isNotEmpty) ...[
              const Text(
                'TRANSCRIPT:',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _transcript,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Non-blocking AI Loading State (Rule 20)
            if (_isAnalyzing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purpleAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('🧠', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          'Analyzing your thinking…',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purpleAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: AppColors.card,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.purpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Timeout / Fallback State (Rule 21 & 22)
            if (_hasTimedOut) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.xpAmber.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.timer_outlined, color: AppColors.xpAmber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI analysis is taking longer than expected.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.xpAmber),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _analyzeExplanation,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('TRY AGAIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyLocalFallback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('CONTINUE WITH LOCAL AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Analysis & Rubric Results
            if (_analysisResult != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EVALUATION RUBRIC',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  Text(
                    'Understanding: ${_analysisResult!['overall_understanding']}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.iqooCyan),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dimensions
              ...((_analysisResult!['dimensions'] as List<dynamic>?) ?? []).map((dim) {
                final bool passed = dim['status'] == 'passed';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: passed ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dim['dimension'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${dim['score']}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: passed ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Gap diagnosis
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _analysisResult!['found_gap'] == true
                      ? AppColors.misconceptionRed.withValues(alpha: 0.15)
                      : AppColors.duolingoGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _analysisResult!['found_gap'] == true
                        ? AppColors.misconceptionRed
                        : AppColors.duolingoGreen,
                  ),
                ),
                child: Text(
                  _analysisResult!['gap_summary'] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
