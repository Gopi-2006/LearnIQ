import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/gemini_config.dart';
import '../models/doubt_response.dart';

/// Production-ready Universal Doubt Service.
///
/// Features:
/// 1. Dual-Path Engine: Automatically connects to local FastAPI backend when available,
///    and seamlessly falls back to Direct Gemini AI + Google Search Grounding in APK/phone mode.
/// 2. Google Search Grounding: Queries Google Search for live, factual citations.
/// 3. Resilient Fallback: If search tool hits quota, seamlessly falls back to Gemini's
///    in-depth knowledge base so students ALWAYS get an answer.
/// 4. Instant Greeting & Intent Filter: Instant zero-latency responses for greetings and gibberish.
class UniversalDoubtService {
  /// Candidate backend URLs to attempt before falling back to direct Gemini API.
  static List<String> get candidateBackendUrls {
    if (kIsWeb) return ['http://127.0.0.1:8000'];
    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        'http://127.0.0.1:8000', // Works via `adb reverse tcp:8000 tcp:8000`
        'http://10.0.2.2:8000', // Works in Android Emulator
        'http://192.168.1.101:8000', // Local development Wi-Fi LAN
      ];
    }
    return ['http://127.0.0.1:8000'];
  }

  /// Primary entry point for student doubt resolution.
  Future<DoubtResponse> askQuestion({
    required String question,
    String? conversationId,
    String? course,
    String? pythonVersion,
  }) async {
    final cleanQ = question.trim();
    if (cleanQ.isEmpty) {
      return DoubtResponse(
        success: false,
        mode: 'UNKNOWN_INPUT',
        answer: "Please type a question you'd like help understanding!",
        subject: 'General',
        webSearched: false,
        sources: const [],
      );
    }

    // Fast-path: Instant on-device resolution for Greetings
    if (_isGreeting(cleanQ)) {
      return DoubtResponse(
        success: true,
        mode: 'GREETING',
        answer:
            "Hello! I am Chami, your LearnIQ AI Study Companion.\n\n"
            "What topic, concept, or code are you learning today? "
            "Ask me anything, and I'll break it down step by step!",
        subject: course ?? 'General',
        webSearched: false,
        sources: const [],
      );
    }

    // Fast-path: Rephrase prompt for pure gibberish
    if (_isGibberish(cleanQ)) {
      return DoubtResponse(
        success: false,
        mode: 'UNKNOWN_INPUT',
        answer:
            "I didn't quite catch that. Could you please rephrase your question "
            "or specify what concept you'd like to understand?",
        subject: 'General',
        webSearched: false,
        sources: const [],
      );
    }

    // Step 1: Attempt local backend if available (short timeout)
    final backendResult = await _tryBackend(
      question: cleanQ,
      conversationId: conversationId,
      course: course,
      pythonVersion: pythonVersion,
    );

    if (backendResult != null && backendResult.success) {
      return backendResult;
    }

    // Step 2: Direct Gemini AI + Google Search Grounding (APK & Standalone Mode)
    debugPrint('[UniversalDoubtService] Backend unavailable. Calling Gemini API directly...');
    return await _callGeminiDirect(
      question: cleanQ,
      course: course,
    );
  }

  /// Attempts to query the local FastAPI backend.
  Future<DoubtResponse?> _tryBackend({
    required String question,
    String? conversationId,
    String? course,
    String? pythonVersion,
  }) async {
    for (final host in candidateBackendUrls) {
      try {
        final response = await http
            .post(
              Uri.parse('$host/api/ask-learn-iq'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'question': question,
                'conversationId': conversationId,
                'course': course,
                'pythonVersion': pythonVersion,
              }),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          return DoubtResponse.fromJson(Map<String, dynamic>.from(data));
        }
      } catch (_) {
        // Continue trying next candidate
      }
    }
    return null;
  }

  /// Direct Gemini API call with Google Search Grounding for APK mode.
  Future<DoubtResponse> _callGeminiDirect({
    required String question,
    String? course,
  }) async {
    final apiKey = GeminiConfig.apiKey;
    final model = GeminiConfig.modelName;

    const systemInstruction =
        "You are LearnIQ AI, an expert, concise, and direct programming and educational companion.\n\n"
        "CRITICAL RULES:\n"
        "1. DIRECT ANSWER: Answer the user's specific question directly and immediately. Never give unprompted lectures or irrelevant analogies.\n"
        "2. CODE FIRST: When code or syntax is requested (e.g. 'python code to print hello world'), output the correct, working code snippet in markdown syntax FIRST, followed by a concise explanation.\n"
        "3. CONCISE & CLEAR: Keep explanations focused, accurate, and easy to read. Avoid verbose filler or unnecessary preambles.\n"
        "4. ACCURACY: Answer precisely according to modern programming standards and verified facts.";

    final promptText =
        "${course != null && course.isNotEmpty ? 'Subject context: $course\n' : ''}"
        "Question: $question\n\n"
        "Answer the user's question directly. If code is requested, provide the working code snippet first.";

    // Attempt 1: Gemini with Google Search Tool Grounding
    try {
      final searchResult = await _executeGeminiRequest(
        apiKey: apiKey,
        model: model,
        prompt: promptText,
        systemInstruction: systemInstruction,
        enableGoogleSearch: true,
      );
      if (searchResult != null) {
        return searchResult;
      }
    } catch (e) {
      debugPrint('[UniversalDoubtService] Search grounding failed or quota reached: $e');
    }

    // Attempt 2: Fallback to Gemini without search tool (guarantees student gets an answer)
    try {
      final directResult = await _executeGeminiRequest(
        apiKey: apiKey,
        model: model,
        prompt: promptText,
        systemInstruction: systemInstruction,
        enableGoogleSearch: false,
      );
      if (directResult != null) {
        return directResult;
      }
    } on SocketException catch (_) {
      return DoubtResponse(
        success: false,
        mode: 'NO_INTERNET',
        answer:
            "NO INTERNET CONNECTION\n\n"
            "Please check your Wi-Fi or mobile data connection and try again.",
        subject: 'Offline',
        webSearched: false,
        sources: const [],
        errorType: 'NO_INTERNET',
        errorMessage: 'Network is unreachable.',
      );
    } catch (e) {
      debugPrint('[UniversalDoubtService] Direct Gemini call error: $e');
      final errStr = e.toString();
      if (errStr.contains('429') || errStr.contains('RESOURCE_EXHAUSTED')) {
        return DoubtResponse(
          success: false,
          mode: 'RATE_LIMIT',
          answer:
              "AI SERVICE BUSY\n\n"
              "The AI tutor is receiving high demand right now. Please wait a moment and tap Retry.",
          subject: 'General',
          webSearched: false,
          sources: const [],
          errorType: 'RATE_LIMIT',
          errorMessage: 'Gemini API rate limit exceeded.',
        );
      }
    }

    return DoubtResponse(
      success: false,
      mode: 'NO_INTERNET',
      answer:
          "NO INTERNET CONNECTION\n\n"
          "Please verify your device is connected to the internet.",
      subject: 'Offline',
      webSearched: false,
      sources: const [],
      errorType: 'NO_INTERNET',
      errorMessage: 'Network request failed.',
    );
  }

  /// Sends REST request to Google Generative Language API.
  Future<DoubtResponse?> _executeGeminiRequest({
    required String apiKey,
    required String model,
    required String prompt,
    required String systemInstruction,
    required bool enableGoogleSearch,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final Map<String, dynamic> body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      }
    };

    if (enableGoogleSearch) {
      body['tools'] = [
        {'google_search': {}}
      ];
    }

    final resp = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 25));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final cand = candidates.first as Map<String, dynamic>;
      final content = cand['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      final answerText = (parts != null && parts.isNotEmpty)
          ? (parts.first['text'] as String? ?? '')
          : '';

      if (answerText.isEmpty) return null;

      // Extract Grounding Metadata
      final groundingMetadata =
          cand['groundingMetadata'] as Map<String, dynamic>?;
      final webQueries = (groundingMetadata?['webSearchQueries'] as List?)
              ?.map((q) => q.toString())
              .toList() ??
          [];
      final rawChunks =
          (groundingMetadata?['groundingChunks'] as List?) ?? [];

      final List<DoubtSource> sources = [];
      for (final c in rawChunks) {
        if (c is Map<String, dynamic>) {
          final web = c['web'] as Map<String, dynamic>?;
          if (web != null) {
            final uri = web['uri'] as String? ?? '';
            final title = web['title'] as String? ?? '';
            String domain = '';
            try {
              if (uri.isNotEmpty) {
                domain = Uri.parse(uri).host;
              }
            } catch (_) {}

            if (uri.isNotEmpty && title.isNotEmpty) {
              sources.add(DoubtSource(
                title: title,
                url: uri,
                domain: domain.isNotEmpty ? domain : 'web',
              ));
            }
          }
        }
      }

      final hasWebGrounding = sources.isNotEmpty || webQueries.isNotEmpty;

      return DoubtResponse(
        success: true,
        mode: hasWebGrounding ? 'WEB_GROUNDED' : 'EXPLANATION',
        answer: answerText,
        subject: 'General',
        webSearched: hasWebGrounding,
        sources: sources,
        confidence: hasWebGrounding ? 'HIGH' : 'MEDIUM',
      );
    } else if (resp.statusCode == 429) {
      throw Exception('HTTP 429 RESOURCE_EXHAUSTED');
    } else {
      debugPrint('[UniversalDoubtService] Gemini returned ${resp.statusCode}: ${resp.body}');
      return null;
    }
  }

  bool _isGreeting(String q) {
    final lower = q.toLowerCase().replaceAll(RegExp(r'[!.,?]'), '').trim();
    const greetings = [
      'hi',
      'hii',
      'hiii',
      'hello',
      'hey',
      'heyy',
      'good morning',
      'good afternoon',
      'good evening',
      'thanks',
      'thank you',
      'who are you',
      'what is your name',
    ];
    return greetings.contains(lower);
  }

  bool _isGibberish(String q) {
    final clean = q.trim();
    if (clean.length < 3) return false;
    final lettersOnly = clean.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (lettersOnly.length < 3) return false;

    // Check for repetitive characters like "aaaaa" or "asdfasdf"
    final uniqueChars = lettersOnly.toLowerCase().split('').toSet();
    if (uniqueChars.length <= 2 && lettersOnly.length >= 6) return true;

    const gibberish = ['asdf', 'qwerty', 'zxcv', 'xyzabc', 'qwertyuiop'];
    for (final g in gibberish) {
      if (lettersOnly.toLowerCase().contains(g) && lettersOnly.length < 15) {
        return true;
      }
    }
    return false;
  }
}
