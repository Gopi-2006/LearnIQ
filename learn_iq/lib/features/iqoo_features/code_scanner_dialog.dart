import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';

class CodeScannerDialog extends StatefulWidget {
  const CodeScannerDialog({super.key});

  @override
  State<CodeScannerDialog> createState() => _CodeScannerDialogState();
}

class _CodeScannerDialogState extends State<CodeScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;
  String _selectedPreset = 'textbook_func';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _performScan();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _performScan() async {
    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final res = await ApiService.scanCode(snippetId: _selectedPreset);

    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanResult = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.camera_alt, color: AppColors.iqooCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'iQOO VISION CODE SCANNER',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.iqooCyan,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Point camera at textbook code or screens to instantly detect concepts and logic bugs.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // Viewfinder / Reticle
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF070A0F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.5)),
                ),
                child: Stack(
                  children: [
                    // Corner targeting reticles
                    const Positioned(top: 8, left: 8, child: Icon(Icons.crop_free, color: AppColors.iqooCyan, size: 24)),
                    const Positioned(top: 8, right: 8, child: Icon(Icons.crop_free, color: AppColors.iqooCyan, size: 24)),
                    const Positioned(bottom: 8, left: 8, child: Icon(Icons.crop_free, color: AppColors.iqooCyan, size: 24)),
                    const Positioned(bottom: 8, right: 8, child: Icon(Icons.crop_free, color: AppColors.iqooCyan, size: 24)),

                    // Scanning laser line
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Positioned(
                            top: 140 * _animController.value,
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.iqooCyan,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.iqooCyan.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    Center(
                      child: _isScanning
                          ? const Text(
                              'SCANNING OCR & PARSING AST...',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.iqooCyan),
                            )
                          : const Text(
                              'READY • CODE IN FOCUS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.duolingoGreen),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Sample Presets Switcher
              Row(
                children: [
                  const Text('Sample: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ChoiceChip(
                    label: const Text('Textbook Function Bug', style: TextStyle(fontSize: 11)),
                    selected: _selectedPreset == 'textbook_func',
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedPreset = 'textbook_func');
                        _performScan();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Loop Sum', style: TextStyle(fontSize: 11)),
                    selected: _selectedPreset == 'loop_sum',
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedPreset = 'loop_sum');
                        _performScan();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // OCR Results & Pedagogical Guidance
              if (_scanResult != null) ...[
                const Text(
                  'EXTRACTED CODE:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _scanResult!['extracted_code'] ?? '',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFE6EDF3)),
                  ),
                ),
                const SizedBox(height: 12),

                // Bug diagnosis if any
                if (_scanResult!['has_bugs'] == true) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.misconceptionRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bug_report, color: AppColors.misconceptionRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scanResult!['bug_diagnosis'] ?? '',
                            style: const TextStyle(fontSize: 11, color: AppColors.misconceptionRed, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Socratic Guidance
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.psychology, color: AppColors.iqooCyan, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _scanResult!['pedagogical_guidance'] ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
