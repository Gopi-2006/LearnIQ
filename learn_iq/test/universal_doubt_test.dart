import 'package:flutter_test/flutter_test.dart';
import 'package:learn_iq/core/services/universal_doubt_service.dart';
import 'package:learn_iq/core/services/verified_python_explanation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UniversalDoubtService & Multi-Subject Doubt Engine Tests', () {
    test('Offline query returns rich curriculum and NEVER produces UNABLE TO VERIFY', () async {
      final service = UniversalDoubtService();

      final offlineQueries = [
        'What is Python?',
        'What is Java?',
        'What is an API?',
        'What is binary search?',
        'What is HTML?',
        'What is a variable?',
      ];

      for (final query in offlineQueries) {
        final result = await service.ask(
          question: query,
          forceOffline: true,
        );

        expect(result.status, equals('offline'));
        expect(result.isOffline, isTrue);
        expect(result.title.toUpperCase(), isNot(contains('UNABLE TO VERIFY')));
        expect(result.directAnswer.toUpperCase(), isNot(contains('UNABLE TO VERIFY')));
        expect(result.directAnswer.isNotEmpty, isTrue);
        expect(result.explanationSections.analogy.isNotEmpty, isTrue);
        expect(result.explanationSections.howItWorks.isNotEmpty, isTrue);
        expect(result.sources.isNotEmpty, isTrue);
      }
    });

    test('UniversalDoubtResult JSON Serialization & Deserialization roundtrip', () {
      final sampleJson = {
        'status': 'success',
        'question': 'What is binary search?',
        'subject': 'Algorithms',
        'title': 'Binary Search Algorithm (O(log n))',
        'direct_answer': 'Binary search is an efficient divide-and-conquer algorithm...',
        'code_example': 'def binary_search(arr, target): ...',
        'sources': [
          {
            'title': 'Algorithms Guide',
            'url': 'https://en.wikipedia.org/wiki/Binary_search_algorithm',
            'domain': 'wikipedia.org',
            'score': 0.85,
          }
        ],
        'verified': true,
        'confidence': 'high',
        'explanation_sections': {
          'summary': 'Binary search runs in O(log n) time.',
          'analogy': 'Like opening a dictionary in the middle.',
          'how_it_works': 'Halves the search space at each iteration.',
          'example': 'arr = [1, 3, 5, 7, 9]',
          'pitfalls': 'Array must be sorted.',
          'key_takeaway': 'O(log n) scales to billions of items.',
        },
        'search_mode': 'online_web_search',
      };

      final parsed = UniversalDoubtResult.fromJson(sampleJson);
      expect(parsed.isVerified, isTrue);
      expect(parsed.subject, equals('Algorithms'));
      expect(parsed.sources.length, equals(1));
      expect(parsed.sources.first.domain, equals('wikipedia.org'));
      expect(parsed.explanationSections.analogy, contains('dictionary'));

      final reserialized = parsed.toJson();
      expect(reserialized['status'], equals('success'));
      expect(reserialized['subject'], equals('Algorithms'));
    });

    test('VerifiedExplanationResult.fromUniversalResult maps fields cleanly without breaking legacy consumers', () {
      const univ = UniversalDoubtResult(
        status: 'success',
        question: 'What is inheritance in Java?',
        subject: 'Java',
        title: 'Java OOP Inheritance',
        directAnswer: 'Inheritance allows a subclass to acquire methods from a parent class.',
        codeExample: 'class Dog extends Animal {}',
        sources: [
          DoubtSource(
            title: 'Oracle Java Docs',
            url: 'https://docs.oracle.com/en/java/',
            domain: 'oracle.com',
          )
        ],
        verified: true,
        confidence: 'high',
      );

      final legacyResult = VerifiedExplanationResult.fromUniversalResult(univ);
      expect(legacyResult.isVerified, isTrue);
      expect(legacyResult.subject, equals('Java'));
      expect(legacyResult.title, equals('Java OOP Inheritance'));
      expect(legacyResult.sourceTitle, equals('Oracle Java Docs'));
      expect(legacyResult.sourceUrl, equals('https://docs.oracle.com/en/java/'));
      expect(legacyResult.title.toUpperCase(), isNot(contains('UNABLE TO VERIFY')));
    });
  });
}
