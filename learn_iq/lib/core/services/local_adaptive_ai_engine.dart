import 'dart:math';

enum ExplanationTier {
  directExplanation,
  simpleAnalogy,
  visualRepresentation,
  tinyExample,
  stepByStepWalkthrough,
}

class AdaptiveEvaluationResult {
  final bool isCorrect;
  final String teacherFeedback;
  final String? mistakeCause;
  final ExplanationTier explanationTier;
  final String adaptiveExplanation;
  final String? visualDiagram;
  final String? miniCodeSnippet;
  final List<String>? stepGuide;
  final double masteryDelta;
  final bool isMastered;

  AdaptiveEvaluationResult({
    required this.isCorrect,
    required this.teacherFeedback,
    this.mistakeCause,
    required this.explanationTier,
    required this.adaptiveExplanation,
    this.visualDiagram,
    this.miniCodeSnippet,
    this.stepGuide,
    required this.masteryDelta,
    this.isMastered = false,
  });
}

class ProveUnderstandResult {
  final bool isSatisfactory;
  final double confidenceScore;
  final String chamiCritique;
  final List<String> identifiedConcepts;
  final List<String> missingElements;

  ProveUnderstandResult({
    required this.isSatisfactory,
    required this.confidenceScore,
    required this.chamiCritique,
    required this.identifiedConcepts,
    required this.missingElements,
  });
}

/// 100% Offline AI Adaptive Learning Engine for LearnIQ.
/// Evaluates student mistakes, escalates through a 5-tier explanation system,
/// prevents repetition of mastered topics, and evaluates conceptual understanding.
class LocalAdaptiveAiEngine {
  static final LocalAdaptiveAiEngine _instance = LocalAdaptiveAiEngine._internal();
  factory LocalAdaptiveAiEngine() => _instance;
  LocalAdaptiveAiEngine._internal();

  // Tracks repeat mistakes per (topicId, studentId)
  final Map<String, int> _consecutiveMistakes = {};

  /// Evaluates student answer using patient teacher persona and 5-tier adaptive escalation
  AdaptiveEvaluationResult evaluateSubmission({
    required String topicId,
    required String studentAnswer,
    required String expectedAnswer,
    String? codeContext,
    double currentMastery = 0.5,
  }) {
    final cleanStudent = studentAnswer.trim().toLowerCase();
    final cleanExpected = expectedAnswer.trim().toLowerCase();
    final isCorrect = cleanStudent == cleanExpected;

    if (isCorrect) {
      _consecutiveMistakes[topicId] = 0;
      final newMastery = min(1.0, currentMastery + 0.18);
      final isMastered = newMastery >= 0.85;

      return AdaptiveEvaluationResult(
        isCorrect: true,
        teacherFeedback: isMastered
            ? 'Outstanding! You have demonstrated verified mastery over this topic! 🎉'
            : 'Spot on! Your programming intuition is getting sharper with every step.',
        explanationTier: ExplanationTier.directExplanation,
        adaptiveExplanation: 'Your solution matches the expected Python runtime execution.',
        masteryDelta: 0.18,
        isMastered: isMastered,
      );
    }

    // -------------------------------------------------------------
    // MISTAKE HANDLING: NEVER SAY "YOU ARE WRONG"
    // -------------------------------------------------------------
    final mistakeCount = (_consecutiveMistakes[topicId] ?? 0) + 1;
    _consecutiveMistakes[topicId] = mistakeCount;

    // Escalate explanation tier based on repeated mistakes
    final ExplanationTier tier = _getEscalationTier(mistakeCount);
    final String mistakeCause = _diagnoseMistake(cleanStudent, cleanExpected, codeContext);

    final explanationData = _buildTieredExplanation(topicId, mistakeCause, tier);

    return AdaptiveEvaluationResult(
      isCorrect: false,
      teacherFeedback: 'Almost! Your idea is close. Let\'s look at the small discrepancy.',
      mistakeCause: mistakeCause,
      explanationTier: tier,
      adaptiveExplanation: explanationData['explanation'] as String,
      visualDiagram: explanationData['visual'] as String?,
      miniCodeSnippet: explanationData['snippet'] as String?,
      stepGuide: explanationData['steps'] as List<String>?,
      masteryDelta: -0.12,
      isMastered: false,
    );
  }

  ExplanationTier _getEscalationTier(int mistakeCount) {
    switch (mistakeCount) {
      case 1:
        return ExplanationTier.directExplanation;
      case 2:
        return ExplanationTier.simpleAnalogy;
      case 3:
        return ExplanationTier.visualRepresentation;
      case 4:
        return ExplanationTier.tinyExample;
      default:
        return ExplanationTier.stepByStepWalkthrough;
    }
  }

  String _diagnoseMistake(String student, String expected, String? context) {
    final ctx = (context ?? '').toLowerCase();

    if (ctx.contains('print') && (expected.contains('return') || expected.contains('none'))) {
      return 'return_vs_print';
    }
    if (ctx.contains('[') || ctx.contains('index') || ctx.contains('range')) {
      if (student.contains('3') && expected.contains('2')) return 'zero_based_bounds';
      if (student.contains('5') && expected.contains('4')) return 'off_by_one_range';
    }
    if (student.contains('=') && !student.contains('==') && expected.contains('==')) {
      return 'assignment_vs_comparison';
    }
    if (ctx.contains('    ') || student.contains('indent')) {
      return 'scope_indentation';
    }
    return 'logic_ordering';
  }

  Map<String, dynamic> _buildTieredExplanation(String topicId, String mistakeCause, ExplanationTier tier) {
    switch (tier) {
      case ExplanationTier.directExplanation:
        return {
          'explanation': _getDirectExplanation(mistakeCause),
          'visual': null,
          'snippet': null,
          'steps': null,
        };

      case ExplanationTier.simpleAnalogy:
        return {
          'explanation': _getSimpleAnalogy(mistakeCause),
          'visual': null,
          'snippet': null,
          'steps': null,
        };

      case ExplanationTier.visualRepresentation:
        return {
          'explanation': 'Here is a visual map of how Python evaluates this in memory:',
          'visual': _getVisualDiagram(mistakeCause),
          'snippet': null,
          'steps': null,
        };

      case ExplanationTier.tinyExample:
        return {
          'explanation': 'Let\'s isolate this into a 2-line mini example:',
          'visual': null,
          'snippet': _getTinyExampleSnippet(mistakeCause),
          'steps': null,
        };

      case ExplanationTier.stepByStepWalkthrough:
        return {
          'explanation': 'Let\'s solve this together step by step so you never get stuck on this again:',
          'visual': null,
          'snippet': null,
          'steps': _getStepByStepGuide(mistakeCause),
        };
    }
  }

  String _getDirectExplanation(String cause) {
    switch (cause) {
      case 'return_vs_print':
        return 'print() displays text onto the screen for human eyes and gives back None. return hands the calculated value directly back to your program in memory.';
      case 'zero_based_bounds':
        return 'Python uses 0-based indexing. For a 3-element list, valid positions are 0, 1, and 2. Index 3 is out of range!';
      case 'off_by_one_range':
        return 'range(start, stop) stops BEFORE the stop value. range(1, 5) generates 1, 2, 3, 4.';
      case 'assignment_vs_comparison':
        return '= assigns a value to a variable. == checks whether two values are equal.';
      case 'scope_indentation':
        return 'Python requires 4 spaces of indentation to know which lines belong inside a function or loop block.';
      default:
        return 'Python evaluates lines sequentially from top to bottom. Make sure dependent variables are defined first.';
    }
  }

  String _getSimpleAnalogy(String cause) {
    switch (cause) {
      case 'return_vs_print':
        return 'Think of a restaurant: print() is a waiter shouting "Your food is ready!" but hands you an empty plate. return is the chef actually placing the burger into your hands to eat!';
      case 'zero_based_bounds':
        return 'Think of index as footsteps away from the starting line. The very first runner is 0 steps away from the tape!';
      case 'off_by_one_range':
        return 'Think of range(1, 5) like a countdown timer stopping right as it reaches 5—it never counts the 5 itself.';
      case 'assignment_vs_comparison':
        return '= is an arrow pouring water into a glass. == is a scale checking if two glasses weigh the same.';
      default:
        return 'Think of programming instructions like an origami diagram: step 1 must fold before step 2 can exist.';
    }
  }

  String _getVisualDiagram(String cause) {
    switch (cause) {
      case 'return_vs_print':
        return '📢 print("Hi")   ---> [Screen Terminal]\n📦 result = None   ---> [Computer RAM]\n\n🥫 return "Hi"    ---> [Computer RAM: result = "Hi"]';
      case 'zero_based_bounds':
        return 'List Items: [ "Apple",  "Banana",  "Cherry" ]\nIndex:           0          1          2\n                  ↑ Valid    ↑ Valid    ↑ Valid\nIndex 3:         [ ❌ IndexError: Out of Bounds ]';
      case 'off_by_one_range':
        return 'range(0, 4) ---> [ 0 ] [ 1 ] [ 2 ] [ 3 ]  (Stops at 4 - 1 = 3)';
      default:
        return 'Line 1: def setup()  ---> Block begins\nLine 2:     action() ---> 4 spaces indented';
    }
  }

  String _getTinyExampleSnippet(String cause) {
    switch (cause) {
      case 'return_vs_print':
        return 'def give_five():\n    return 5\n\nx = give_five()\nprint(x * 2)  # Output: 10';
      case 'zero_based_bounds':
        return 'nums = [10, 20]\nprint(nums[0])  # First: 10\nprint(nums[1])  # Second: 20';
      default:
        return 'x = 10\nif x > 5:\n    print("Safe!")';
    }
  }

  List<String> _getStepByStepGuide(String cause) {
    switch (cause) {
      case 'return_vs_print':
        return [
          'Step 1: Ask yourself: Do I need this value later in the code?',
          'Step 2: If yes, use the "return" keyword inside the function.',
          'Step 3: When calling the function, capture it with a variable: answer = my_func()',
        ];
      case 'zero_based_bounds':
        return [
          'Step 1: Count total items in the list: len(items)',
          'Step 2: The highest accessible index is always len(items) - 1',
          'Step 3: To get the last item safely, use index -1: items[-1]',
        ];
      default:
        return [
          'Step 1: Read the problem objective carefully.',
          'Step 2: Verify all variable names match their spelling.',
          'Step 3: Trace values line-by-line as the interpreter executes.',
        ];
    }
  }

  /// "Prove You Understand" Feynman technique activity evaluation
  ProveUnderstandResult evaluateProveUnderstand({
    required String topicId,
    required String studentExplanation,
  }) {
    final text = studentExplanation.toLowerCase().trim();
    if (text.length < 15) {
      return ProveUnderstandResult(
        isSatisfactory: false,
        confidenceScore: 0.2,
        chamiCritique: 'That\'s a bit brief! Try expanding on what the computer actually does in memory.',
        identifiedConcepts: [],
        missingElements: ['Mechanism explanation', 'Real-world example'],
      );
    }

    final identified = <String>[];
    final missing = <String>[];

    // Check key concept signals by topic
    if (topicId.contains('return') || topicId.contains('function')) {
      if (text.contains('value') || text.contains('pass') || text.contains('send') || text.contains('give')) {
        identified.add('Value transfer mechanism');
      } else {
        missing.add('How data passes to caller');
      }

      if (text.contains('screen') || text.contains('show') || text.contains('display') || text.contains('console')) {
        identified.add('Output differentiation');
      }
    } else if (topicId.contains('list') || topicId.contains('index')) {
      if (text.contains('zero') || text.contains('0') || text.contains('start')) {
        identified.add('Zero-based start rule');
      } else {
        missing.add('Zero-based start offset');
      }

      if (text.contains('bound') || text.contains('length') || text.contains('size') || text.contains('order')) {
        identified.add('Sequence boundaries');
      }
    } else {
      identified.add('Core conceptual intent');
    }

    final score = min(1.0, 0.4 + (identified.length * 0.3) + (text.length > 50 ? 0.2 : 0.0));
    final isSatisfactory = score >= 0.70;

    return ProveUnderstandResult(
      isSatisfactory: isSatisfactory,
      confidenceScore: score,
      chamiCritique: isSatisfactory
          ? 'Brilliant! You explained this like a true engineer. You understand the inner workings!'
          : 'Good effort! You captured parts of it. Try mentioning: ${missing.join(", ")}.',
      identifiedConcepts: identified,
      missingElements: missing,
    );
  }
}
