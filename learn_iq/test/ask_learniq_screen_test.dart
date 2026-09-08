import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_iq/models/doubt_response.dart';
import 'package:learn_iq/widgets/answer_card.dart';
import 'package:learn_iq/widgets/doubt_input.dart';
import 'package:learn_iq/widgets/source_card.dart';

void main() {
  group('Ask LearnIQ Modular Widgets & Models Tests', () {
    test('DoubtResponse and DoubtSource JSON serialization & deserialization', () {
      final sampleJson = {
        'success': true,
        'answer': 'Python is a high-level programming language...',
        'subject': 'Python',
        'topic': 'Introduction',
        'webSearched': true,
        'confidence': 'high',
        'sources': [
          {
            'title': 'Python Documentation',
            'url': 'https://docs.python.org/3/',
            'domain': 'docs.python.org',
          }
        ],
      };

      final response = DoubtResponse.fromJson(sampleJson);
      expect(response.success, isTrue);
      expect(response.subject, equals('Python'));
      expect(response.webSearched, isTrue);
      expect(response.sources.length, equals(1));
      expect(response.sources.first.domain, equals('docs.python.org'));
      expect(response.sources.first.title, equals('Python Documentation'));
    });

    testWidgets('DoubtInput renders correctly and responds to submit', (tester) async {
      final controller = TextEditingController(text: 'What is an API?');
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubtInput(
              controller: controller,
              onSubmitted: () {
                submitted = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('What is an API?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submitted, isTrue);
    });

    testWidgets('AnswerCard displays web-searched answer and sources', (tester) async {
      final response = DoubtResponse(
        success: true,
        answer: 'Binary search is an O(log n) search algorithm.',
        subject: 'Algorithms',
        webSearched: true,
        sources: [
          DoubtSource(
            title: 'Wikipedia — Binary search',
            url: 'https://en.wikipedia.org/wiki/Binary_search_algorithm',
            domain: 'wikipedia.org',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerCard(response: response),
          ),
        ),
      );

      expect(find.text('WEB-SEARCHED ANSWER'), findsOneWidget);
      expect(find.text('Algorithms'), findsOneWidget);
      expect(find.text('Binary search is an O(log n) search algorithm.'), findsOneWidget);
      expect(find.text('SOURCES'), findsOneWidget);
      expect(find.text('Wikipedia — Binary search'), findsOneWidget);
      expect(find.text('wikipedia.org'), findsOneWidget);
    });

    testWidgets('SourceCard renders clickable title and domain', (tester) async {
      final source = DoubtSource(
        title: 'Oracle Java Documentation',
        url: 'https://docs.oracle.com/en/java/',
        domain: 'oracle.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceCard(source: source),
          ),
        ),
      );

      expect(find.text('Oracle Java Documentation'), findsOneWidget);
      expect(find.text('oracle.com'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });
    testWidgets('AnswerCard displays greeting card for GREETING mode', (tester) async {
      final response = DoubtResponse(
        success: true,
        mode: 'GREETING',
        answer: "Hi! 👋\n\nI'm LearnIQ.\n\nAsk me anything you're learning, and I'll help you understand it.",
        webSearched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerCard(response: response),
          ),
        ),
      );

      expect(find.text('LEARNIQ'), findsOneWidget);
      expect(find.textContaining('Ask me anything'), findsOneWidget);
      expect(find.text('SOURCES'), findsNothing);
      expect(find.text('RECONNECT & RETRY'), findsNothing);
    });

    testWidgets('AnswerCard displays unknown input card for UNKNOWN_INPUT mode', (tester) async {
      final response = DoubtResponse(
        success: false,
        mode: 'UNKNOWN_INPUT',
        answer: "I couldn't understand that question.\n\nTry asking something like:\n• What is Python?\n• What is a variable?",
        webSearched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerCard(response: response),
          ),
        ),
      );

      expect(find.text("I DIDN'T UNDERSTAND"), findsOneWidget);
      expect(find.textContaining('Try asking something like:'), findsOneWidget);
      expect(find.text('SOURCES'), findsNothing);
    });

    testWidgets('AnswerCard displays search unavailable card with retry for SEARCH_ERROR / OFFLINE mode', (tester) async {
      bool retryTriggered = false;
      final response = DoubtResponse(
        success: false,
        mode: 'SEARCH_FAILED',
        answer: "I couldn't search the web right now. Reconnect and try again.",
        webSearched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerCard(
              response: response,
              onRetry: () {
                retryTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('WEB SEARCH TEMPORARILY UNAVAILABLE'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);

      await tester.tap(find.text('RETRY'));
      await tester.pump();
      expect(retryTriggered, isTrue);
    });
  });
}
