import 'python_knowledge_service.dart';
import 'universal_doubt_service.dart';

enum VerificationStatus {
  verified,
  partiallyVerified,
  offline,
  searchFailed,
  sourceNotFound,
  sourceUnreadable,
  verificationFailed,
  aiGenerationFailed,
  unverified,
}

class VerifiedExplanationResult {
  final String question;
  final String title;
  final String explanation;
  final String? codeExample;
  final String pythonVersion;
  final String? sourceTitle;
  final String? sourceUrl;
  final String subject;
  final List<DoubtSource>? sources;
  final String confidence;
  final VerificationStatus status;
  final DateTime? verifiedAt;
  final bool fromCache;

  const VerifiedExplanationResult({
    required this.question,
    required this.title,
    required this.explanation,
    this.codeExample,
    this.pythonVersion = 'Python 3.13',
    this.sourceTitle,
    this.sourceUrl,
    this.subject = 'Technology',
    this.sources,
    this.confidence = 'high',
    required this.status,
    this.verifiedAt,
    this.fromCache = false,
  });

  bool get isVerified => status == VerificationStatus.verified;
  bool get isOffline => status == VerificationStatus.offline;
  bool get isSearchFailed => status == VerificationStatus.searchFailed;
  bool get isSourceNotFound => status == VerificationStatus.sourceNotFound;
  bool get isVerificationFailed => status == VerificationStatus.verificationFailed;
  bool get isUnverified =>
      status == VerificationStatus.unverified ||
      status == VerificationStatus.searchFailed ||
      status == VerificationStatus.sourceNotFound ||
      status == VerificationStatus.verificationFailed ||
      status == VerificationStatus.sourceUnreadable ||
      status == VerificationStatus.aiGenerationFailed;

  factory VerifiedExplanationResult.fromUniversalResult(UniversalDoubtResult univ) {
    final st = univ.isOffline
        ? VerificationStatus.offline
        : (univ.isVerified ? VerificationStatus.verified : VerificationStatus.unverified);
    final firstSrc = univ.sources.isNotEmpty ? univ.sources.first : null;
    return VerifiedExplanationResult(
      question: univ.question,
      title: univ.title,
      explanation: univ.directAnswer,
      codeExample: univ.codeExample,
      subject: univ.subject,
      sources: univ.sources,
      confidence: univ.confidence,
      pythonVersion: univ.subject == 'Python' ? 'Python 3.13' : 'Target: ${univ.subject}',
      sourceTitle: firstSrc?.title ?? 'Verified Documentation',
      sourceUrl: firstSrc?.url ?? 'https://learniq.ai/knowledge',
      status: st,
      verifiedAt: univ.verifiedAt,
      fromCache: univ.fromCache,
    );
  }

  factory VerifiedExplanationResult.offline({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "NO INTERNET CONNECTION",
      explanation:
          "You're offline.\n\nLearnIQ can't search Python documentation right now without an active internet connection.\n\nReconnect to the internet and try again.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.offline,
    );
  }

  factory VerifiedExplanationResult.searchFailed({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "SEARCH TEMPORARILY UNAVAILABLE",
      explanation:
          "The internet is working, but the search service didn't respond.\n\nPlease try again.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.searchFailed,
    );
  }

  factory VerifiedExplanationResult.sourceNotFound({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "COULDN'T FIND A RELIABLE SOURCE",
      explanation:
          "I couldn't find enough authoritative information to answer this safely.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.sourceNotFound,
    );
  }

  factory VerifiedExplanationResult.sourceUnreadable({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "SOURCE UNREADABLE",
      explanation:
          "Could not parse the retrieved official documentation.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.sourceUnreadable,
    );
  }

  factory VerifiedExplanationResult.verificationFailed({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "COULDN'T VERIFY THE ANSWER",
      explanation:
          "I found information, but I couldn't verify the explanation confidently.\n\nPlease try again.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.verificationFailed,
    );
  }

  factory VerifiedExplanationResult.aiGenerationFailed({
    required String question,
    String pythonVersion = 'Python 3.13',
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "GENERATION FAILED",
      explanation:
          "Unable to synthesize the verified documentation. Please try again.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.aiGenerationFailed,
    );
  }

  factory VerifiedExplanationResult.unverified({
    required String question,
    String pythonVersion = 'Python 3.13',
    String? customMessage,
  }) {
    return VerifiedExplanationResult(
      question: question,
      title: "Unable to Verify",
      explanation: customMessage ??
          "I couldn't verify this Python explanation right now against official documentation.\n\nPlease try again.",
      pythonVersion: pythonVersion,
      status: VerificationStatus.unverified,
    );
  }

  factory VerifiedExplanationResult.fromBackendJson(
    Map<String, dynamic> json,
    String question, {
    bool fromCache = false,
  }) {
    final statusStr = (json['status'] as String? ?? 'unverified').toLowerCase();
    VerificationStatus st;
    if (statusStr == 'verified' || json['verified'] == true) {
      st = VerificationStatus.verified;
    } else if (statusStr == 'offline') {
      st = VerificationStatus.offline;
    } else if (statusStr == 'search_failed') {
      st = VerificationStatus.searchFailed;
    } else if (statusStr == 'source_not_found') {
      st = VerificationStatus.sourceNotFound;
    } else if (statusStr == 'verification_failed') {
      st = VerificationStatus.verificationFailed;
    } else if (statusStr == 'partially_verified') {
      st = VerificationStatus.partiallyVerified;
    } else {
      st = VerificationStatus.unverified;
    }

    final explanationText = json['direct_answer'] as String? ??
        json['answer'] as String? ??
        json['message'] as String? ??
        json['explanation'] as String? ??
        '';

    DateTime? parsedTime;
    if (json['verified_at'] != null) {
      parsedTime = DateTime.tryParse(json['verified_at'] as String);
    }

    String? sourceTitle = json['source_title'] as String?;
    String? sourceUrl = json['source_url'] as String?;

    if (json['sources'] is List && (json['sources'] as List).isNotEmpty) {
      final firstSrc = (json['sources'] as List)[0];
      if (firstSrc is Map) {
        sourceTitle ??= firstSrc['title'] as String?;
        sourceUrl ??= firstSrc['url'] as String?;
      }
    }

    return VerifiedExplanationResult(
      question: question,
      title: json['title'] as String? ?? (st == VerificationStatus.verified ? 'Verified Explanation' : 'Unable to Verify'),
      explanation: explanationText,
      codeExample: json['code_example'] as String?,
      pythonVersion: json['python_version'] as String? ?? 'Python 3.13',
      sourceTitle: sourceTitle ?? 'Python Official Documentation',
      sourceUrl: sourceUrl ?? 'https://docs.python.org/3/',
      status: st,
      verifiedAt: parsedTime ?? DateTime.now(),
      fromCache: fromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'title': title,
        'explanation': explanation,
        'code_example': codeExample,
        'python_version': pythonVersion,
        'source_title': sourceTitle,
        'source_url': sourceUrl,
        'status': status.name,
        'verified_at': verifiedAt?.toIso8601String(),
      };

  factory VerifiedExplanationResult.fromJson(Map<String, dynamic> json) {
    VerificationStatus st = VerificationStatus.unverified;
    for (final val in VerificationStatus.values) {
      if (val.name == json['status']) {
        st = val;
        break;
      }
    }
    return VerifiedExplanationResult(
      question: json['question'] as String? ?? '',
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      codeExample: json['code_example'] as String?,
      pythonVersion: json['python_version'] as String? ?? 'Python 3.13',
      sourceTitle: json['source_title'] as String?,
      sourceUrl: json['source_url'] as String?,
      status: st,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      fromCache: true,
    );
  }
}

/// Backward compatibility layer delegating completely to the unified [PythonKnowledgeService].
class VerifiedPythonExplanationService {
  static final VerifiedPythonExplanationService _instance = VerifiedPythonExplanationService._internal();
  factory VerifiedPythonExplanationService() => _instance;
  VerifiedPythonExplanationService._internal();

  Future<bool> isInternetAvailable() => PythonKnowledgeService().isInternetAvailable();

  Future<VerifiedExplanationResult> explain({
    required String question,
    String pythonVersion = 'Python 3.13',
    String? codeContext,
    bool forceOffline = false,
  }) {
    return PythonKnowledgeService().explain(
      question: question,
      pythonVersion: pythonVersion,
      codeContext: codeContext,
      forceOffline: forceOffline,
    );
  }

  VerifiedExplanationResult? resolveAuthoritativeFallback(String query, [String version = 'Python 3.13']) {
    final normalized = PythonKnowledgeService().normalizeQuery(query);
    final rawLower = query.toLowerCase();

    // Direct lookup in PythonKnowledgeService authoritative corpus
    final doc = PythonKnowledgeService.authoritativeDocCorpus[normalized];
    if (doc != null) {
      return PythonKnowledgeService().generateExplanation(
        question: query,
        source: doc,
        pythonVersion: version,
      );
    }

    for (final entry in PythonKnowledgeService.authoritativeDocCorpus.entries) {
      final data = entry.value;
      final keywords = data['keywords'] as List<String>;
      for (final kw in keywords) {
        if (normalized == kw || rawLower.contains(kw) || normalized.contains(kw)) {
          return PythonKnowledgeService().generateExplanation(
            question: query,
            source: data,
            pythonVersion: version,
          );
        }
      }
    }

    return null;
  }
}
