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
}
