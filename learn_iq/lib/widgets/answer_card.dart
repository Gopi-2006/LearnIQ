import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/doubt_response.dart';
import 'source_card.dart';

class AnswerCard extends StatelessWidget {
  final DoubtResponse response;
  final VoidCallback? onRetry;

  const AnswerCard({
    super.key,
    required this.response,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (response.isGreeting) {
      return _buildGreetingCard(context);
    }
    if (response.isUnknownInput) {
      return _buildUnknownInputCard(context);
    }
    if (response.isOffline) {
      return _buildOfflineCard(context);
    }
    if (response.isError) {
      return _buildSearchErrorCard(context);
    }

    return _buildGroundedAnswerCard(context);
  }

  /// 1. Calm Greeting Card (Section 11)
  Widget _buildGreetingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👋', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Text(
                'LEARNIQ',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            response.answer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Unknown Input Card (Section 12: Clear Guidance, No Hallucinations)
  Widget _buildUnknownInputCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amberAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🤔', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Text(
                "I DIDN'T UNDERSTAND",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            response.answer,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Offline Card (Section 17 & 31: NO INTERNET CONNECTION)
  Widget _buildOfflineCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amberAccent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.amberAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'NO INTERNET CONNECTION',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            response.answer,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 4. Error Cards (Section 31: SEARCH_FAILED, GEMINI_ERROR, RATE_LIMIT, SEARCH_TIMEOUT)
  Widget _buildSearchErrorCard(BuildContext context) {
    String titleText = 'WEB SEARCH TEMPORARILY UNAVAILABLE';
    IconData errorIcon = Icons.warning_amber_rounded;
    Color accentColor = Colors.pinkAccent;

    if (response.isTimeout) {
      titleText = 'SEARCH TIMEOUT';
      errorIcon = Icons.timer_outlined;
      accentColor = Colors.orangeAccent;
    } else if (response.isRateLimit) {
      titleText = 'AI SERVICE BUSY';
      errorIcon = Icons.hourglass_top_rounded;
      accentColor = Colors.amberAccent;
    } else if (response.isGeminiError) {
      titleText = 'AI SERVICE TEMPORARILY UNAVAILABLE';
      errorIcon = Icons.error_outline;
      accentColor = Colors.deepOrangeAccent;
    } else if (response.isSearchFailed) {
      titleText = 'WEB SEARCH TEMPORARILY UNAVAILABLE';
      errorIcon = Icons.search_off_rounded;
      accentColor = Colors.pinkAccent;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161B24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(errorIcon, color: accentColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            response.answer.isNotEmpty
                ? response.answer
                : (response.errorMessage ?? "Web search is temporarily unavailable."),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: accentColor == Colors.amberAccent ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 5. Intelligent Structured Answer Card (Section 14: Clear Pedagogical Presentation)
  Widget _buildGroundedAnswerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge & Subject
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      response.webSearched ? Icons.public : Icons.auto_awesome,
                      color: Colors.cyanAccent,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      response.webSearched ? 'WEB-SEARCHED ANSWER' : 'AI ANSWER',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (response.subject.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B24),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    response.subject,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Answer Section Content (Broken down into readable blocks)
          _buildStructuredAnswerBlocks(context, response.answer),

          const SizedBox(height: 28),

          // Sources Section (Displayed only when genuine sources exist)
          if (response.sources.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 15, color: Colors.cyanAccent),
                SizedBox(width: 8),
                Text(
                  'SOURCES',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...response.sources.map((source) => SourceCard(source: source)),
          ],
        ],
      ),
    );
  }

  /// Parses markdown code fences (```lang ... ```) and text blocks for clean pedagogical layout
  Widget _buildStructuredAnswerBlocks(BuildContext context, String rawAnswer) {
    final parts = rawAnswer.split('```');
    final widgets = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.trim().isEmpty) continue;

      if (i % 2 == 1) {
        // Code Block
        final lines = part.split('\n');
        String language = 'code';
        String codeBody = part;

        if (lines.isNotEmpty && lines.first.trim().isNotEmpty && lines.first.trim().length < 15) {
          language = lines.first.trim();
          codeBody = lines.skip(1).join('\n');
        }

        widgets.add(_buildCodeBlock(context, language, codeBody.trimRight()));
      } else {
        // Narrative / Educational text block
        widgets.add(_buildTextSection(part.trim()));
      }
      widgets.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Formats narrative paragraphs with high readability
  Widget _buildTextSection(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.65,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// Formats code snippets with copy button and dark elevated styling
  Widget _buildCodeBlock(BuildContext context, String language, String code) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code block top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF121620),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: Colors.white54),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF76E4F7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
