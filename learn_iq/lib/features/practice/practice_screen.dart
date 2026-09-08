import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/learning_models.dart';
import '../../core/models/story_curriculum_models.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../lesson/engine/scenes/parsons_lab_widget.dart';
import '../lesson/engine/scenes/bug_hunter_widget.dart';
import '../lesson/engine/ask_learn_iq_sheet.dart';
import 'weak_areas_screen.dart';
import '../../screens/ask_learniq_screen.dart';

class PracticeScreen extends StatefulWidget {
  final LearningStateManager stateManager;

  const PracticeScreen({super.key, required this.stateManager});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'PRACTICE LAB & ARENA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.iqooCyan),
            tooltip: 'Ask LearnIQ Study Companion',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AskLearnIQScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.psychology, color: AppColors.misconceptionRed),
            tooltip: 'My Weak Areas',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => WeakAreasScreen(stateManager: widget.stateManager),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.iqooCyan,
          labelColor: AppColors.iqooCyan,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.pest_control, size: 20), text: 'Debug Arena'),
            Tab(icon: Icon(Icons.radar, size: 20), text: 'Review Radar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebugArenaTab(),
          _buildReviewRadarTab(),
        ],
      ),
    );
  }

  Widget _buildDebugArenaTab() {
    final problems = widget.stateManager.debugProblems;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ==========================================
        // KINESTHETIC MULTI-MODAL LABS (SIGNATURE SHOWCASE)
        // ==========================================
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F1535), Color(0xFF131A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.purpleAccent.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleAccent.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 14, color: AppColors.iqooCyan),
                        SizedBox(width: 4),
                        Text(
                          'KINESTHETIC ARENA MODES',
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
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.duolingoGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ACTIVE AI TWIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.duolingoGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Tactile Code Engines & Shadow Diagnostics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Experience spatial Parsons logic with indentation controls and radar laser bug hunting.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 16),

              // Two Signature Interactive Mode Cards
              Row(
                children: [
                  // Mode 1: Parsons Lab Card
                  Expanded(
                    child: InkWell(
                      onTap: () => _launchParsonsLabModal(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.extension, size: 18, color: AppColors.iqooCyan),
                                const Spacer(),
                                if (widget.stateManager.student.isNewLearner)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.iqooCyan.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'DIAGNOSTIC',
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.iqooCyan),
                                    ),
                                  )
                                else
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Parsons Lab',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.stateManager.student.isNewLearner
                                  ? 'Diagnostic Preview'
                                  : 'Scope & Indent Puzzle',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.iqooCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  widget.stateManager.student.isNewLearner ? 'PREVIEW LAB' : 'PLAY LAB',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.iqooCyan,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Mode 2: Bug Hunter Card
                  Expanded(
                    child: InkWell(
                      onTap: () => _launchBugHunterModal(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pest_control, size: 18, color: AppColors.misconceptionRed),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Bug Hunter',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Radar Scanner Patcher',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.misconceptionRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'PLAY HUNTER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.misconceptionRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // AI Doubt Solver Banner
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AskLearnIQScreen()),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.iqooCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: AppColors.iqooCyan, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASK LEARNIQ DOUBT BOX',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.iqooCyan,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Instant offline textbook search + web AI synthesis for code questions.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Section Title: Sandbox Arena Challenges
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            'SANDBOX ARENA CHALLENGES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Problem cards
        ...problems.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.xpAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${p.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xpAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.misconceptionRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.errorType,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.misconceptionRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Broken Code Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1017),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    p.brokenCode,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.xpAmber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.hint,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showFixDialog(p);
                    },
                    icon: const Icon(Icons.pest_control, size: 18),
                    label: const Text('HUNT & FIX IN BUG HUNTER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.misconceptionRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _launchParsonsLabModal(BuildContext context) {
    const defaultParsonsProblem = ParsonsProblemData(
      id: 'parsons_loop_01',
      title: 'Even Numbers Filter Loop',
      objective: 'Assemble a script that loops through numbers and prints only the even values with correct 4-space scoping.',
      concept: 'python.loops.for',
      blocks: [
        ParsonsBlock(id: 'b1', text: 'nums = [1, 2, 3, 4, 5, 6]', correctIndentLevel: 0),
        ParsonsBlock(id: 'b2', text: 'for n in nums:', correctIndentLevel: 0),
        ParsonsBlock(id: 'b3', text: 'if n % 2 == 0:', correctIndentLevel: 1),
        ParsonsBlock(id: 'b4', text: 'print(f"Even: {n}")', correctIndentLevel: 2),
      ],
      correctSequenceIds: ['b1', 'b2', 'b3', 'b4'],
      solutionExplanation: 'The for-loop iterates through each number. Inside the loop (indented 4 spaces), the if-statement tests divisibility. The print statement is nested (indented 8 spaces).',
      softPauseHint: 'Start with list definition "nums = ...", then the "for" loop header, then the "if" condition with indentation.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PARSONS LAB ARENA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.iqooCyan,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                Expanded(
                  child: ParsonsLabWidget(
                    problem: defaultParsonsProblem,
                    onCompleted: (success) {
                      if (success) {
                        widget.stateManager.addExperience(35);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Parsons Lab Completed! +35 XP earned.'),
                            backgroundColor: AppColors.duolingoGreen,
                          ),
                        );
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (ctx.mounted) Navigator.pop(ctx);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchBugHunterModal(BuildContext context, [DebugProblem? problem]) {
    final BugHunterProblemData bugProblem = problem != null
        ? BugHunterProblemData(
            id: problem.id,
            title: problem.title,
            scenario: 'Runtime inspection triggered by: ${problem.errorType}. Hint: ${problem.hint}',
            concept: 'python.debugging',
            lines: [
              const BugHunterLine(lineNumber: 1, text: '# Diagnostic run', isBuggy: false),
              BugHunterLine(lineNumber: 2, text: problem.brokenCode, isBuggy: true),
              const BugHunterLine(lineNumber: 3, text: 'print("Execution verified.")', isBuggy: false),
            ],
            buggyLineNumber: 2,
            bugExplanation: 'Line 2 causes an unexpected error: ${problem.errorType}.',
            fixOptions: [
              BugHunterFixOption(
                id: 'fix_correct',
                label: 'Apply Correct Patch',
                fixedCode: problem.expectedFix,
                isCorrect: true,
                feedback: 'Optimal fix! Resolves the bug cleanly.',
              ),
              const BugHunterFixOption(
                id: 'fix_alt',
                label: 'Suppress with pass statement',
                fixedCode: 'pass  # bypass bug',
                isCorrect: false,
                feedback: 'Bypassing does not resolve the logic error.',
              ),
            ],
            expectedOutput: 'Execution verified.\n>>> Process completed successfully (exit code 0)',
            brokenErrorOutput: 'Traceback (most recent call last):\n  File "debug.py", line 2\n    ${problem.brokenCode}\n${problem.errorType}',
          )
        : const BugHunterProblemData(
            id: 'hunter_default_01',
            title: 'Index Bounds Breakdown',
            scenario: 'An autonomous rover encountered an index overflow in its battery cell reader!',
            concept: 'python.lists.indexing',
            lines: [
              BugHunterLine(lineNumber: 1, text: 'cells = [3.7, 3.8, 3.6]', isBuggy: false, cleanInspectionHint: 'Line 1 is a valid 3-element float list.'),
              BugHunterLine(lineNumber: 2, text: 'print("Reading battery health...")', isBuggy: false, cleanInspectionHint: 'Line 2 is a valid console string output.'),
              BugHunterLine(lineNumber: 3, text: 'critical_cell = cells[3]', isBuggy: true),
              BugHunterLine(lineNumber: 4, text: 'print(f"Cell voltage: {critical_cell}V")', isBuggy: false),
            ],
            buggyLineNumber: 3,
            bugExplanation: 'cells has 3 items (indices 0, 1, 2). Accessing index 3 triggers an IndexError.',
            fixOptions: [
              BugHunterFixOption(
                id: 'fix_01',
                label: 'Access last element (index 2)',
                fixedCode: 'critical_cell = cells[2]',
                isCorrect: true,
                feedback: 'Index 2 targets the 3rd and final cell (3.6V).',
              ),
              BugHunterFixOption(
                id: 'fix_02',
                label: 'Change to cells[4]',
                fixedCode: 'critical_cell = cells[4]',
                isCorrect: false,
                feedback: 'Index 4 is even farther out of bounds!',
              ),
              BugHunterFixOption(
                id: 'fix_03',
                label: 'Use string index cells["3"]',
                fixedCode: 'critical_cell = cells["3"]',
                isCorrect: false,
                feedback: 'Indices must be integers, not strings (TypeError).',
              ),
            ],
            expectedOutput: 'Reading battery health...\nCell voltage: 3.6V\n>>> Process completed successfully (exit code 0)',
            brokenErrorOutput: 'Traceback (most recent call last):\n  File "battery_scan.py", line 3\n    critical_cell = cells[3]\nIndexError: list index out of range',
          );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BUG HUNTER ARENA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.misconceptionRed,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                Expanded(
                  child: BugHunterWidget(
                    problem: bugProblem,
                    onCompleted: (success) {
                      if (success) {
                        widget.stateManager.addExperience(40);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Bug Hunter Mission Cleared! +40 XP earned.'),
                            backgroundColor: AppColors.duolingoGreen,
                          ),
                        );
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (ctx.mounted) Navigator.pop(ctx);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFixDialog(DebugProblem p) {
    _launchBugHunterModal(context, p);
  }

  Widget _buildReviewRadarTab() {
    final student = widget.stateManager.student;
    final concepts = student.concepts;
    final hasEvidence = student.hasLearningEvidence && concepts.isNotEmpty;

    // Find real decaying concept with evidence
    MapEntry<String, ConceptMastery>? decayingConcept;
    if (hasEvidence) {
      for (final entry in concepts.entries) {
        if (entry.value.hasEnoughEvidence && entry.value.retention < 0.60) {
          if (decayingConcept == null || entry.value.retention < decayingConcept.value.retention) {
            decayingConcept = entry;
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Launch Full Weak Areas Dashboard Card
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => WeakAreasScreen(stateManager: widget.stateManager),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1A29), Color(0xFF141926)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.misconceptionRed.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: AppColors.misconceptionRed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MY WEAK AREAS DASHBOARD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.misconceptionRed,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Inspect AI Twin cognitive radar & launch targeted repair drills.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          // Radar Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.misconceptionRed.withValues(alpha: 0.15),
                  AppColors.card,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.misconceptionRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.radar, color: AppColors.misconceptionRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI FORGETTING RADAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.misconceptionRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'LearnIQ detects which concepts are decaying before you fail an exam or code challenge.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        !hasEvidence
                            ? Icons.info_outline
                            : (decayingConcept != null ? Icons.warning_amber_rounded : Icons.check_circle_outline),
                        color: !hasEvidence
                            ? AppColors.textSecondary
                            : (decayingConcept != null ? AppColors.misconceptionRed : AppColors.duolingoGreen),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          !hasEvidence
                              ? 'Not enough learning data yet to track memory decay.'
                              : (decayingConcept != null
                                  ? '🔴 ${decayingConcept.key.toUpperCase()} (${(decayingConcept.value.retention * 100).toInt()}% retention) shows active decay.'
                                  : '🟢 All evaluated concepts are currently retaining stably (>75%).'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'ESTIMATED CONCEPT RETENTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          if (!hasEvidence)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: const [
                  Icon(Icons.hourglass_empty_rounded, size: 36, color: AppColors.textMuted),
                  SizedBox(height: 10),
                  Text(
                    'No Retention Evidence Yet',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Complete lessons and answer questions so LearnIQ can measure your concept memory curves.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else ...[
            // Concept Retention Cards
            ...concepts.entries.map((entry) {
              final name = entry.key;
              final data = entry.value;
              final int retPct = (data.retention * 100).toInt();
              Color statusColor = AppColors.duolingoGreen;
              String statusLabel = '🟢 STABLE';

              if (data.retention < 0.50) {
                statusColor = AppColors.misconceptionRed;
                statusLabel = '🔴 CRITICAL DECAY';
              } else if (data.retention < 0.75) {
                statusColor = AppColors.xpAmber;
                statusLabel = '🟡 FRAGILE';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name.toUpperCase(),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: data.retention,
                              minHeight: 8,
                              backgroundColor: AppColors.surface,
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$retPct%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: statusColor),
                        ),
                        const Text('Retention', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final target = decayingConcept?.key ?? concepts.keys.first;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting 3-minute spaced review for ${target.toUpperCase()}...'),
                      backgroundColor: AppColors.iqooCyan,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('START 3-MIN SMART REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iqooCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugFixDialog extends StatefulWidget {
  final DebugProblem problem;
  final LearningStateManager stateManager;

  const _DebugFixDialog({
    required this.problem,
    required this.stateManager,
  });

  @override
  State<_DebugFixDialog> createState() => _DebugFixDialogState();
}

class _DebugFixDialogState extends State<_DebugFixDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.problem.expectedFix);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Fix: ${p.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter the corrected code line:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.stateManager.submitAnswer(
              exerciseId: p.id,
              concept: 'debug_arena',
              questionType: 'bug_fix',
              studentAnswer: _controller.text,
              expectedAnswer: p.expectedFix,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Bug Fixed! +${p.xpReward} XP earned.'),
                backgroundColor: AppColors.duolingoGreen,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.duolingoGreen,
            foregroundColor: Colors.black,
          ),
          child: const Text('SUBMIT FIX'),
        ),
      ],
    );
  }
}
