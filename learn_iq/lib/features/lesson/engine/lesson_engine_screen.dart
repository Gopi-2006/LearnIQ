import 'package:flutter/material.dart';
import '../../../core/models/story_curriculum_models.dart';
import '../../../core/services/learning_state_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';
import 'scenes/story_scene_widget.dart';
import 'scenes/interactive_game_widget.dart';
import 'scenes/interactive_code_widget.dart';
import 'scenes/prove_you_understand_dialog.dart';
import '../../../core/widgets/verified_explanation_card.dart';
import 'ask_learn_iq_sheet.dart';
import '../../../screens/ask_learniq_screen.dart';

class LessonEngineScreen extends StatefulWidget {
  final StoryConcept concept;
  final LearningStateManager stateManager;
  final bool isTargetedFixLaunch;

  const LessonEngineScreen({
    super.key,
    required this.concept,
    required this.stateManager,
    this.isTargetedFixLaunch = false,
  });

  @override
  State<LessonEngineScreen> createState() => _LessonEngineScreenState();
}

class _LessonEngineScreenState extends State<LessonEngineScreen> {
  int _currentSceneIndex = 0;
  String? _selectedOption;
  List<String> _orderedBlocks = [];
  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;
  String? _feedbackExplanation;
  bool _isGameCompleted = false;
  bool _isLessonComplete = false;
  int _sessionXpGained = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.lesson('Starting Story Lesson: "${widget.concept.title}" (${widget.concept.scenes.length} scenes)');
    if (widget.isTargetedFixLaunch) {
      // Find targetedFix scene or default to middle
      final fixIndex = widget.concept.scenes.indexWhere((s) => s.type == SceneType.targetedFix);
      if (fixIndex != -1) {
        _currentSceneIndex = fixIndex;
      }
    }
    _initSceneState();
  }

  void _initSceneState() {
    final scene = widget.concept.scenes[_currentSceneIndex];
    _selectedOption = null;
    _isAnswerChecked = false;
    _isAnswerCorrect = false;
    _feedbackExplanation = null;
    _isGameCompleted = false;

    if (scene.codeBlocks != null && scene.codeBlocks!.isNotEmpty) {
      _orderedBlocks = List<String>.from(scene.codeBlocks!)..shuffle();
    } else {
      _orderedBlocks = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLessonComplete) {
      return _buildCelebrationScreen();
    }

    final scene = widget.concept.scenes[_currentSceneIndex];
    final progress = (_currentSceneIndex + 1) / widget.concept.scenes.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(widget.concept.themeColor),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.iqooCyan),
            tooltip: 'Ask LearnIQ Study Companion',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AskLearnIQScreen(course: widget.concept.title),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.energyOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.stateManager.student.energy}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scene type pill badge
                    Row(
                      children: [
                        Text(widget.concept.themeEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.concept.unitTitle.toUpperCase()} • SCENE ${_currentSceneIndex + 1}/${widget.concept.scenes.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: widget.concept.themeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Scene Content based on Type
                    _buildSceneBody(scene),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomBar(scene),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneBody(StorySceneItem scene) {
    switch (scene.type) {
      case SceneType.storyHook:
      case SceneType.problem:
      case SceneType.conceptReveal:
      case SceneType.codeReveal:
        return StorySceneWidget(
          scene: scene,
          themeColor: widget.concept.themeColor,
        );

      case SceneType.interactiveGame:
        return Column(
          children: [
            StorySceneWidget(
              scene: scene,
              themeColor: widget.concept.themeColor,
            ),
            const SizedBox(height: 16),
            InteractiveGameWidget(
              scene: scene,
              onGameCompleted: (val) {
                setState(() {
                  _isGameCompleted = val;
                });
              },
            ),
          ],
        );

      case SceneType.discovery:
      case SceneType.microPractice:
      case SceneType.targetedFix:
      case SceneType.masteryChallenge:
        return Column(
          children: [
            StorySceneWidget(
              scene: scene,
              themeColor: widget.concept.themeColor,
            ),
            const SizedBox(height: 16),
            InteractiveCodeWidget(
              scene: scene,
              selectedOption: _selectedOption,
              orderedBlocks: _orderedBlocks,
              onOptionSelected: (opt) {
                if (!_isAnswerChecked) {
                  setState(() {
                    _selectedOption = opt;
                  });
                }
              },
              onOrderChanged: (newOrder) {
                if (!_isAnswerChecked) {
                  setState(() {
                    _orderedBlocks = newOrder;
                  });
                }
              },
            ),
          ],
        );

      case SceneType.celebration:
        return StorySceneWidget(
          scene: scene,
          themeColor: widget.concept.themeColor,
        );
    }
  }

  Widget _buildBottomBar(StorySceneItem scene) {
    final bool isQuestionScene = scene.type == SceneType.discovery ||
        scene.type == SceneType.microPractice ||
        scene.type == SceneType.targetedFix ||
        scene.type == SceneType.masteryChallenge;

    final bool isGameScene = scene.type == SceneType.interactiveGame;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback Banner if checked
          if (_isAnswerChecked) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isAnswerCorrect
                    ? AppColors.duolingoGreen.withValues(alpha: 0.15)
                    : AppColors.misconceptionRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAnswerCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                ),
              ),
              child: Row(
                children: [
                  Text(_isAnswerCorrect ? '🎉' : '🤔', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAnswerCorrect ? 'Correct! +10 XP' : 'Not quite right!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _isAnswerCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                          ),
                        ),
                        if (_feedbackExplanation != null)
                          Text(
                            _feedbackExplanation!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerifiedSourceBadge(
              sourceTitle: widget.concept.verifiedSourceTitle,
              sourceUrl: widget.concept.verifiedSourceUrl,
              pythonVersion: 'Python 3.13',
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _getButtonOnPressed(isQuestionScene, isGameScene),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswerChecked
                    ? (_isAnswerCorrect ? AppColors.duolingoGreen : AppColors.misconceptionRed)
                    : widget.concept.themeColor,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.card,
                disabledForegroundColor: AppColors.textMuted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _getButtonText(isQuestionScene),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _getButtonOnPressed(bool isQuestionScene, bool isGameScene) {
    if (_isAnswerChecked) {
      return () => _handleNextScene();
    }

    if (isQuestionScene) {
      if (_selectedOption != null || _orderedBlocks.isNotEmpty) {
        return () => _handleCheckAnswer();
      }
      return null;
    }

    if (isGameScene) {
      if (_isGameCompleted) {
        return () => _handleNextScene();
      }
      return () => _handleNextScene(); // Allow exploring
    }

    // Story Scene
    return () => _handleNextScene();
  }

  String _getButtonText(bool isQuestionScene) {
    if (_isAnswerChecked) {
      return _currentSceneIndex < widget.concept.scenes.length - 1
          ? 'CONTINUE →'
          : 'COMPLETE LESSON 🎉';
    }

    if (isQuestionScene) {
      return 'CHECK ANSWER';
    }

    return _currentSceneIndex < widget.concept.scenes.length - 1
        ? 'CONTINUE ➔'
        : 'FINISH ADVENTURE 🎉';
  }

  void _handleCheckAnswer() {
    final scene = widget.concept.scenes[_currentSceneIndex];
    final isCorrect = _selectedOption == scene.correctOption;

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = isCorrect;
      _feedbackExplanation = scene.explanation ?? (isCorrect ? 'Well done!' : 'Review the concept and try again.');
      if (isCorrect) {
        _sessionXpGained += 10;
        widget.stateManager.addExperience(10);
      }
    });

    if (!isCorrect && scene.misconceptionKey != null) {
      _showStoryMisconceptionModal(scene);
    }
  }

  void _handleNextScene() {
    if (_currentSceneIndex < widget.concept.scenes.length - 1) {
      setState(() {
        _currentSceneIndex++;
        _initSceneState();
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    widget.stateManager.completeLesson(
      widget.concept.id,
      xpBonus: widget.concept.xpReward,
    );
    setState(() {
      _isLessonComplete = true;
    });
  }

  void _showStoryMisconceptionModal(StorySceneItem scene) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161C28),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.misconceptionRed),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                const Text(
                  'AI MISCONCEPTION COACH',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.misconceptionRed,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scene.misconceptionExplanation ?? 'Keep in mind: In Python, displaying text on the screen is not the same as returning a value!',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 8),
            VerifiedSourceBadge(
              sourceTitle: widget.concept.verifiedSourceTitle,
              sourceUrl: widget.concept.verifiedSourceUrl,
              pythonVersion: 'Python 3.13',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.misconceptionRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('GOT IT! CONTINUE PRACTICE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.concept.themeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.concept.themeColor, width: 3),
                  ),
                  child: Center(
                    child: Text(widget.concept.themeEmoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CONCEPT MASTERED!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.concept.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.concept.themeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // XP Earned Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.concept.xpReward + _sessionXpGained} XP EARNED',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Prove You Understand (Feynman Technique)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ProveYouUnderstandDialog.show(
                        context,
                        topicId: widget.concept.id,
                        conceptTitle: widget.concept.title,
                        stateManager: widget.stateManager,
                      );
                    },
                    icon: const Icon(Icons.psychology, color: AppColors.iqooCyan),
                    label: const Text(
                      'PROVE YOU UNDERSTAND (+25 XP)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.iqooCyan,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.iqooCyan, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.duolingoGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'CONTINUE TO COURSE MAP ➔',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
