import 'package:flutter/material.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import 'experience_level_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final LearningStateManager stateManager;

  const LanguageSelectionScreen({super.key, required this.stateManager});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'python';

  final List<Map<String, dynamic>> _languages = [
    {
      'id': 'python',
      'name': 'Python',
      'icon': '🐍',
      'subtitle': 'Most popular • AI, Data & Automation',
      'isAvailable': true,
    },
    {
      'id': 'java',
      'name': 'Java',
      'icon': '☕',
      'subtitle': 'Enterprise & Android Development',
      'isAvailable': false,
    },
    {
      'id': 'javascript',
      'name': 'JavaScript',
      'icon': '🌐',
      'subtitle': 'Web & Interactive Applications',
      'isAvailable': false,
    },
    {
      'id': 'c',
      'name': 'C',
      'icon': '⚙️',
      'subtitle': 'Low-level Systems & Embedded',
      'isAvailable': false,
    },
    {
      'id': 'cpp',
      'name': 'C++',
      'icon': '💻',
      'subtitle': 'High-performance Game Engines',
      'isAvailable': false,
    },
    {
      'id': 'dart',
      'name': 'Dart',
      'icon': '🎯',
      'subtitle': 'Multiplatform Mobile & Flutter',
      'isAvailable': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'STEP 1 OF 4',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.iqooCyan,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What do you want to learn?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'LearnIQ builds an AI Learning Twin tailored to your chosen language.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguage == lang['id'];
                    final isAvailable = lang['isAvailable'] as bool;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: isAvailable
                            ? () {
                                setState(() {
                                  _selectedLanguage = lang['id'];
                                });
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${lang['name']} course is coming soon! Python is live for the hackathon.'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.iqooCyan.withValues(alpha: 0.12)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.iqooCyan
                                  : (isAvailable ? AppColors.border : AppColors.border.withValues(alpha: 0.4)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(lang['icon'], style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          lang['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: isAvailable ? AppColors.textPrimary : AppColors.textMuted,
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'SOON',
                                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lang['subtitle'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isAvailable ? AppColors.textSecondary : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.iqooCyan, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ExperienceLevelScreen(
                          stateManager: widget.stateManager,
                          selectedLanguage: _selectedLanguage,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
