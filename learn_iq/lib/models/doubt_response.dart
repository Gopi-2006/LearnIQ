class DoubtResponse {
  final bool success;
  final String mode;
  final String answer;
  final String subject;
  final String? topic;
  final bool webSearched;
  final String? confidence;
  final List<DoubtSource> sources;
  final String? errorType;
  final String? errorMessage;

  DoubtResponse({
    required this.success,
    this.mode = 'WEB_GROUNDED',
    required this.answer,
    this.subject = 'General',
    this.topic,
    required this.webSearched,
    this.confidence,
    this.sources = const [],
    this.errorType,
    this.errorMessage,
  });

  bool get isGreeting => mode == 'GREETING';
  bool get isWebGrounded => mode == 'WEB_GROUNDED' && webSearched;
  bool get isOffline => mode == 'NO_INTERNET' || mode == 'OFFLINE' || errorType == 'NO_INTERNET';
  bool get isUnknownInput => mode == 'UNKNOWN_INPUT' || errorType == 'UNKNOWN_INPUT';
  bool get isRateLimit => mode == 'RATE_LIMIT' || errorType == 'RATE_LIMIT';
  bool get isGeminiError => mode == 'GEMINI_ERROR' || errorType == 'GEMINI_ERROR';
  bool get isSearchFailed => mode == 'SEARCH_FAILED' || errorType == 'SEARCH_FAILED' || mode == 'NO_RELEVANT_SOURCES';
  bool get isTimeout => mode == 'SEARCH_TIMEOUT' || errorType == 'SEARCH_TIMEOUT';
  bool get isServerError => mode == 'SERVER_ERROR' || errorType == 'SERVER_ERROR';
  bool get isError => !success && !isGreeting && !isUnknownInput;

  factory DoubtResponse.fromJson(Map<String, dynamic> json) {
    final rawMode = (json['mode'] as String? ?? 'WEB_GROUNDED').toUpperCase();
    final bool webSrc = json['webSearched'] ?? false;
    final bool sc = json['success'] ?? (rawMode == 'GREETING' || (rawMode == 'WEB_GROUNDED' && webSrc));

    return DoubtResponse(
      success: sc,
      mode: rawMode,
      answer: json['answer'] ?? '',
      subject: json['subject'] ?? 'General',
      topic: json['topic'],
      webSearched: webSrc,
      confidence: json['confidence'],
      sources: (json['sources'] as List? ?? [])
          .map(
            (source) => DoubtSource.fromJson(
              Map<String, dynamic>.from(source),
            ),
          )
          .toList(),
      errorType: json['errorType'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'mode': mode,
        'answer': answer,
        'subject': subject,
        'topic': topic,
        'webSearched': webSearched,
        'confidence': confidence,
        'sources': sources.map((s) => s.toJson()).toList(),
        'errorType': errorType,
        'errorMessage': errorMessage,
      };
}

class DoubtSource {
  final String title;
  final String url;
  final String? domain;

  DoubtSource({
    required this.title,
    required this.url,
    this.domain,
  });

  factory DoubtSource.fromJson(Map<String, dynamic> json) {
    return DoubtSource(
      title: json['title'] ?? 'Source',
      url: json['url'] ?? '',
      domain: json['domain'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'domain': domain,
      };
}
