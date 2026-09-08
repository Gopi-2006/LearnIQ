import 'package:flutter/material.dart';

enum ChamiEmotion {
  thinking,
  excited,
  alert,
  celebrating,
  guiding,
}

enum SceneType {
  storyHook,
  problem,
  discovery,
  conceptReveal,
  codeReveal,
  interactiveGame,
  microPractice,
  targetedFix,
  masteryChallenge,
  celebration,
}

enum GameType {
  memoryContainers, // Variables (fuel/oxygen/crew bins)
  vendingMachine,   // Functions & Return vs Print
  robotMarchRunner, // Loops (repeat vs for loop)
  gatekeeperBouncer,// Decisions (if/elif/else age/pass)
  inventoryBackpack,// Lists (slots, 0-indexing, append/pop)
  cipherDecoder,    // Strings (indexing, slicing, uppercase)
  reactorStabilizer,// Exceptions (try/except emergency)
  factoryAssembler, // OOP Classes (robot blueprint assembly)
  duplicateHunter,  // Sets (remove duplicates)
  statSheetLookup,  // Dictionaries (key-value lookup)
  terminalProject,  // Final capstone (interactive terminal challenge)
  parsonsLab,       // Parsons drag-and-drop structural code assembly & indentation
  bugHunter,        // Interactive line-by-line syntax bug inspection & patcher
}

class ChamiSpeech {
  final ChamiEmotion emotion;
  final String message;

  const ChamiSpeech({
    required this.emotion,
    required this.message,
  });
}

class StorySceneItem {
  final String id;
  final SceneType type;
  final String title;
  final String narrative;
  final String? worldEmoji;
  final String? worldBadge;
  final ChamiSpeech? chami;
  
  // For Interactive Discovery & Practice
  final String? questionPrompt;
  final String? codeSnippet;
  final List<String>? options;
  final String? correctOption;
  final String? explanation;
  final String? hint;

  // For Interactive Games
  final GameType? gameType;
  final Map<String, dynamic>? gameConfig;

  // For Code Assembly & Ordering
  final List<String>? codeBlocks;
  final List<String>? correctOrder;

  // For Targeted Misconceptions
  final String? misconceptionKey;
  final String? misconceptionExplanation;
  final String? targetedFixCode;

  const StorySceneItem({
    required this.id,
    required this.type,
    required this.title,
    required this.narrative,
    this.worldEmoji,
    this.worldBadge,
    this.chami,
    this.questionPrompt,
    this.codeSnippet,
    this.options,
    this.correctOption,
    this.explanation,
    this.hint,
    this.gameType,
    this.gameConfig,
    this.codeBlocks,
    this.correctOrder,
    this.misconceptionKey,
    this.misconceptionExplanation,
    this.targetedFixCode,
  });
}

class StoryConcept {
  final String id;
  final String title;
  final String unitId;
  final String unitTitle;
  final int unitNumber;
  final int weekNumber;
  final String weekTitle;
  final int dayNumber;
  final int difficulty; // 1 (Intro) to 5 (Advanced)
  final String storyTheme; // e.g. "Space Mission", "Robot Factory", etc.
  final String themeEmoji;
  final Color themeColor;
  final List<StorySceneItem> scenes;
  final int xpReward;
  final List<String> keywords;

  const StoryConcept({
    required this.id,
    required this.title,
    required this.unitId,
    required this.unitTitle,
    required this.unitNumber,
    this.weekNumber = 1,
    this.weekTitle = 'Week 1: Python Origin Mission',
    this.dayNumber = 1,
    required this.difficulty,
    required this.storyTheme,
    required this.themeEmoji,
    required this.themeColor,
    required this.scenes,
    this.xpReward = 50,
    this.keywords = const [],
  });

  String get verifiedSourceTitle {
    final lower = id.toLowerCase();
    if (lower.contains('meet_python') || lower.contains('print')) {
      return 'Python Tutorial (3.13) - An Informal Introduction to Python';
    } else if (lower.contains('variable') || lower.contains('data_type') || lower.contains('math')) {
      return 'Python Tutorial (3.13) - Using Python as a Calculator';
    } else if (lower.contains('decision') || lower.contains('condition') || lower.contains('if')) {
      return 'Python Tutorial (3.13) - More Control Flow Tools: if Statements';
    } else if (lower.contains('loop') || lower.contains('for') || lower.contains('while')) {
      return 'Python Tutorial (3.13) - More Control Flow Tools: for Statements';
    } else if (lower.contains('function')) {
      return 'Python Tutorial (3.13) - More Control Flow Tools: Defining Functions';
    } else if (lower.contains('list')) {
      return 'Python Tutorial (3.13) - Data Structures: More on Lists';
    } else if (lower.contains('dict') || lower.contains('set')) {
      return 'Python Tutorial (3.13) - Data Structures: Dictionaries and Sets';
    } else if (lower.contains('string')) {
      return 'Python Standard Library (3.13) - Built-in Types: Text Sequence Type str';
    } else if (lower.contains('exception') || lower.contains('error')) {
      return 'Python Tutorial (3.13) - Errors and Exceptions';
    } else if (lower.contains('class') || lower.contains('oop')) {
      return 'Python Tutorial (3.13) - Classes and Object-Oriented Programming';
    }
    return 'Python 3.13 Official Documentation';
  }

  String get verifiedSourceUrl {
    final lower = id.toLowerCase();
    if (lower.contains('meet_python') || lower.contains('print')) {
      return 'https://docs.python.org/3/tutorial/introduction.html';
    } else if (lower.contains('variable') || lower.contains('data_type') || lower.contains('math')) {
      return 'https://docs.python.org/3/tutorial/introduction.html#using-python-as-a-calculator';
    } else if (lower.contains('decision') || lower.contains('condition') || lower.contains('if')) {
      return 'https://docs.python.org/3/tutorial/controlflow.html#if-statements';
    } else if (lower.contains('loop') || lower.contains('for') || lower.contains('while')) {
      return 'https://docs.python.org/3/tutorial/controlflow.html#for-statements';
    } else if (lower.contains('function')) {
      return 'https://docs.python.org/3/tutorial/controlflow.html#defining-functions';
    } else if (lower.contains('list')) {
      return 'https://docs.python.org/3/tutorial/datastructures.html#more-on-lists';
    } else if (lower.contains('dict') || lower.contains('set')) {
      return 'https://docs.python.org/3/tutorial/datastructures.html#dictionaries';
    } else if (lower.contains('string')) {
      return 'https://docs.python.org/3/library/stdtypes.html#text-sequence-type-str';
    } else if (lower.contains('exception') || lower.contains('error')) {
      return 'https://docs.python.org/3/tutorial/errors.html';
    } else if (lower.contains('class') || lower.contains('oop')) {
      return 'https://docs.python.org/3/tutorial/classes.html';
    }
    return 'https://docs.python.org/3/';
  }
}

class ParsonsBlock {
  final String id;
  final String text;
  final int correctIndentLevel; // 0, 1 (4 spaces), 2 (8 spaces)
  final String? comment;

  const ParsonsBlock({
    required this.id,
    required this.text,
    this.correctIndentLevel = 0,
    this.comment,
  });
}

class ParsonsProblemData {
  final String id;
  final String title;
  final String objective;
  final String concept;
  final List<ParsonsBlock> blocks;
  final List<String> correctSequenceIds;
  final String solutionExplanation;
  final String softPauseHint;

  const ParsonsProblemData({
    required this.id,
    required this.title,
    required this.objective,
    required this.concept,
    required this.blocks,
    required this.correctSequenceIds,
    required this.solutionExplanation,
    required this.softPauseHint,
  });
}

class BugHunterLine {
  final int lineNumber;
  final String text;
  final bool isBuggy;
  final String? cleanInspectionHint;

  const BugHunterLine({
    required this.lineNumber,
    required this.text,
    this.isBuggy = false,
    this.cleanInspectionHint,
  });
}

class BugHunterFixOption {
  final String id;
  final String fixedCode;
  final String label;
  final bool isCorrect;
  final String feedback;

  const BugHunterFixOption({
    required this.id,
    required this.fixedCode,
    required this.label,
    required this.isCorrect,
    required this.feedback,
  });
}

class BugHunterProblemData {
  final String id;
  final String title;
  final String scenario;
  final String concept;
  final List<BugHunterLine> lines;
  final int buggyLineNumber;
  final String bugExplanation;
  final List<BugHunterFixOption> fixOptions;
  final String expectedOutput;
  final String brokenErrorOutput;

  const BugHunterProblemData({
    required this.id,
    required this.title,
    required this.scenario,
    required this.concept,
    required this.lines,
    required this.buggyLineNumber,
    required this.bugExplanation,
    required this.fixOptions,
    required this.expectedOutput,
    required this.brokenErrorOutput,
  });
}

