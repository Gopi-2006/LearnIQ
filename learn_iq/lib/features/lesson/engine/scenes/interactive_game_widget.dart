import 'package:flutter/material.dart';
import '../../../../core/models/story_curriculum_models.dart';
import '../../../../core/theme/app_theme.dart';
import 'parsons_lab_widget.dart';
import 'bug_hunter_widget.dart';

class InteractiveGameWidget extends StatefulWidget {
  final StorySceneItem scene;
  final ValueChanged<bool> onGameCompleted;

  const InteractiveGameWidget({
    super.key,
    required this.scene,
    required this.onGameCompleted,
  });

  @override
  State<InteractiveGameWidget> createState() => _InteractiveGameWidgetState();
}

class _InteractiveGameWidgetState extends State<InteractiveGameWidget> {
  // Memory Containers State
  final Map<String, String?> _assignedBins = {'fuel': null, 'oxygen': null, 'crew': null};
  final List<String> _unassignedValues = ['100', '80', '5'];
  String? _selectedVal;

  // Vending Machine State
  String? _vendingChoice; // 'print' or 'return'

  // Robot March Runner State
  int _currentStep = 0;
  bool _isMarching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameType = widget.scene.gameType ?? GameType.memoryContainers;

    switch (gameType) {
      case GameType.parsonsLab:
        return _buildParsonsLabScene();
      case GameType.bugHunter:
        return _buildBugHunterScene();
      case GameType.memoryContainers:
        return _buildMemoryContainersGame();
      case GameType.vendingMachine:
        return _buildVendingMachineGame();
      case GameType.robotMarchRunner:
        return _buildRobotMarchGame();
      default:
        return _buildGenericGameCard();
    }
  }

  // ==========================================
  // GAME 1: MEMORY CONTAINERS (Variables)
  // ==========================================
  Widget _buildMemoryContainersGame() {
    final bool allAssigned = _assignedBins['fuel'] == '100' &&
        _assignedBins['oxygen'] == '80' &&
        _assignedBins['crew'] == '5';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('📦', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'SPACESHIP MEMORY BINS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.iqooCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a value below, then tap the matching labeled memory box to assign it (e.g. fuel = 100):',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Labeled Containers
          Row(
            children: [
              _buildMemoryBox('fuel', '100', '⛽'),
              const SizedBox(width: 8),
              _buildMemoryBox('oxygen', '80', '🫁'),
              const SizedBox(width: 8),
              _buildMemoryBox('crew', '5', '👨‍🚀'),
            ],
          ),
          const SizedBox(height: 16),

          // Available values to assign
          const Text(
            'UNASSIGNED TELEMETRY SIGNALS:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _unassignedValues.map((val) {
              final isSelected = _selectedVal == val;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVal = isSelected ? null : val;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.iqooCyan : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (allAssigned) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.duolingoGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.duolingoGreen),
              ),
              child: Row(
                children: const [
                  Text('🎉', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All telemetry stored! fuel=100, oxygen=80, crew=5 locked in RAM!',
                      style: TextStyle(color: AppColors.duolingoGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryBox(String label, String expectedVal, String emoji) {
    final assigned = _assignedBins[label];
    final isCorrect = assigned == expectedVal;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedVal != null) {
            setState(() {
              _assignedBins[label] = _selectedVal;
              _unassignedValues.remove(_selectedVal);
              _selectedVal = null;
            });
            if (_assignedBins['fuel'] == '100' &&
                _assignedBins['oxygen'] == '80' &&
                _assignedBins['crew'] == '5') {
              widget.onGameCompleted(true);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.duolingoGreen.withValues(alpha: 0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect ? AppColors.duolingoGreen : AppColors.border,
              width: isCorrect ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D121B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    assigned ?? '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isCorrect ? AppColors.duolingoGreen : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GAME 2: VENDING MACHINE (Print vs Return)
  // ==========================================
  Widget _buildVendingMachineGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.energyOrange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🥫', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'THE CODE VENDING MACHINE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.energyOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Insert \$2 to buy a Cold Soda. Choose which Python command you want the machine to run:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Physical machine illustration
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2638),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey, width: 3),
              ),
              child: Column(
                children: [
                  // Glass display window
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A101C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const Text('🥤 COLD SODA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          _vendingChoice == 'print'
                              ? 'SCREEN: "Cold Soda"'
                              : (_vendingChoice == 'return' ? 'OUTPUT: DISPENSING...' : 'PRICE: \$2'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _vendingChoice == 'print' ? Colors.amber : AppColors.iqooCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dispensing tray
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        _vendingChoice == 'return'
                            ? '🥤 [ SODA DISPENSED TO HAND ]'
                            : (_vendingChoice == 'print' ? '❌ [ TRAY EMPTY: NONE ]' : '[ TRAY ]'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _vendingChoice == 'return'
                              ? AppColors.duolingoGreen
                              : (_vendingChoice == 'print' ? AppColors.misconceptionRed : Colors.white38),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Choice Buttons: print() vs return
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _vendingChoice = 'print';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _vendingChoice == 'print' ? AppColors.misconceptionRed : AppColors.border,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('def buy():\n    print("Soda")', textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _vendingChoice = 'return';
                    });
                    widget.onGameCompleted(true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _vendingChoice == 'return' ? AppColors.duolingoGreen : AppColors.border,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('def buy():\n    return "Soda"', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),

          if (_vendingChoice != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _vendingChoice == 'return'
                    ? AppColors.duolingoGreen.withValues(alpha: 0.15)
                    : AppColors.misconceptionRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _vendingChoice == 'return'
                    ? '🎉 BINGO! return hands the soda to your hands! `my_drink = buy()` now holds "Soda"!'
                    : '😱 OOPS! print() only flashes "Soda" on the glass screen! Your hands are empty: `my_drink` is None!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _vendingChoice == 'return' ? AppColors.duolingoGreen : AppColors.misconceptionRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // GAME 3: ROBOT MARCH RUNNER (Loops)
  // ==========================================
  Widget _buildRobotMarchGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🤖', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'ROBOT MARCH RUNNER',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: Color(0xFF7C4DFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'March across 5 tiles to reach the recharge battery using a for loop!',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // The 5 Tiles Track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (idx) {
              final isRobotHere = _currentStep == idx;
              final isPassed = _currentStep > idx;
              final isGoal = idx == 4;

              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isRobotHere
                      ? const Color(0xFF7C4DFF)
                      : (isPassed ? AppColors.duolingoGreen.withValues(alpha: 0.2) : AppColors.surface),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isRobotHere ? Colors.white : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isRobotHere ? '🤖' : (isGoal ? '🔋' : '$idx'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Run Loop Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(_isMarching ? 'MARCHING...' : 'RUN: for step in range(5)'),
              onPressed: _isMarching
                  ? null
                  : () async {
                      setState(() {
                        _isMarching = true;
                        _currentStep = 0;
                      });

                      for (int s = 1; s <= 4; s++) {
                        await Future.delayed(const Duration(milliseconds: 400));
                        if (!mounted) return;
                        setState(() {
                          _currentStep = s;
                        });
                      }

                      setState(() {
                        _isMarching = false;
                      });
                      widget.onGameCompleted(true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsonsLabScene() {
    // Check if scene has custom ParsonsProblemData or construct default from codeBlocks
    final problem = ParsonsProblemData(
      id: widget.scene.id,
      title: widget.scene.title.isNotEmpty ? widget.scene.title : 'Structural Scope & Order Challenge',
      objective: widget.scene.narrative.isNotEmpty
          ? widget.scene.narrative
          : 'Reorder the blocks and adjust indentation levels to execute the sequence correctly.',
      concept: widget.scene.misconceptionKey ?? 'python.functions',
      blocks: widget.scene.codeBlocks != null && widget.scene.codeBlocks!.isNotEmpty
          ? widget.scene.codeBlocks!
              .asMap()
              .entries
              .map((e) => ParsonsBlock(
                    id: 'block_${e.key}',
                    text: e.value.trim(),
                    correctIndentLevel: e.value.startsWith('    ') ? 1 : 0,
                  ))
              .toList()
          : const [
              ParsonsBlock(id: 'b1', text: 'def calculate_speed(distance, time):', correctIndentLevel: 0),
              ParsonsBlock(id: 'b2', text: 'if time <= 0:', correctIndentLevel: 1),
              ParsonsBlock(id: 'b3', text: 'return 0', correctIndentLevel: 2),
              ParsonsBlock(id: 'b4', text: 'return distance / time', correctIndentLevel: 1),
              ParsonsBlock(id: 'b5', text: 'print(calculate_speed(100, 5))', correctIndentLevel: 0),
            ],
      correctSequenceIds: widget.scene.correctOrder != null && widget.scene.correctOrder!.isNotEmpty
          ? widget.scene.correctOrder!
              .asMap()
              .entries
              .map((e) => 'block_${e.key}')
              .toList()
          : const ['b1', 'b2', 'b3', 'b4', 'b5'],
      solutionExplanation: widget.scene.explanation ??
          'Python checks conditions in nested blocks: functions and if-statements require 4-space indentation.',
      softPauseHint: widget.scene.hint ??
          'Place "def calculate_speed(...):" first, followed by indented lines.',
    );

    return ParsonsLabWidget(
      problem: problem,
      onCompleted: widget.onGameCompleted,
    );
  }

  Widget _buildBugHunterScene() {
    final problem = BugHunterProblemData(
      id: widget.scene.id,
      title: widget.scene.title.isNotEmpty ? widget.scene.title : 'Zero-Based Index Bug Hunter',
      scenario: widget.scene.narrative.isNotEmpty
          ? widget.scene.narrative
          : 'The ship navigation array crashed on planet approach with an IndexError! Inspect lines to find and patch the invalid index.',
      concept: widget.scene.misconceptionKey ?? 'python.lists.indexing',
      lines: const [
        BugHunterLine(lineNumber: 1, text: 'telemetry_points = [102, 204, 308]', isBuggy: false, cleanInspectionHint: 'Line 1 properly instantiates a list with 3 elements.'),
        BugHunterLine(lineNumber: 2, text: 'print("Acquired coords:")', isBuggy: false, cleanInspectionHint: 'Line 2 is a standard string print statement.'),
        BugHunterLine(lineNumber: 3, text: 'final_point = telemetry_points[3]', isBuggy: true),
        BugHunterLine(lineNumber: 4, text: 'print(final_point)', isBuggy: false, cleanInspectionHint: 'Line 4 correctly outputs the variable.'),
      ],
      buggyLineNumber: 3,
      bugExplanation: 'telemetry_points has length 3, so valid indices are 0, 1, and 2. telemetry_points[3] triggers IndexError!',
      fixOptions: const [
        BugHunterFixOption(
          id: 'fix_1',
          label: 'Change to index 2 (last item)',
          fixedCode: 'final_point = telemetry_points[2]',
          isCorrect: true,
          feedback: 'Correct! telemetry_points[2] targets the 3rd and final item (308).',
        ),
        BugHunterFixOption(
          id: 'fix_2',
          label: 'Change to index 3 + 1',
          fixedCode: 'final_point = telemetry_points[4]',
          isCorrect: false,
          feedback: 'Index 4 is even farther out of range!',
        ),
        BugHunterFixOption(
          id: 'fix_3',
          label: 'Convert index to string "3"',
          fixedCode: 'final_point = telemetry_points["3"]',
          isCorrect: false,
          feedback: 'List indices must be integers or slices, not str (TypeError).',
        ),
      ],
      expectedOutput: 'Acquired coords:\n308\n>>> Process completed successfully (exit code 0)',
      brokenErrorOutput: 'Traceback (most recent call last):\n  File "inspection.py", line 3\n    final_point = telemetry_points[3]\nIndexError: list index out of range',
    );

    return BugHunterWidget(
      problem: problem,
      onCompleted: widget.onGameCompleted,
    );
  }

  Widget _buildGenericGameCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('Interactive challenge ready! Tap Next to continue.'),
    );
  }
}

