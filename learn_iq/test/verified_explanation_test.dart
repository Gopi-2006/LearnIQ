import 'package:flutter_test/flutter_test.dart';
import 'package:learn_iq/core/services/python_knowledge_service.dart';
import 'package:learn_iq/core/services/verified_python_explanation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PythonKnowledgeService & Verified Explanation Pipeline Tests', () {
    test('Offline query returns honest offline state without guessing (Rule #24)', () async {
      final service = PythonKnowledgeService();

      final result = await service.explain(
        question: 'What is a Python dictionary?',
        pythonVersion: 'Python 3.13',
        forceOffline: true,
      );

      expect(result.status, equals(VerificationStatus.offline));
      expect(result.isOffline, isTrue);
      expect(result.title, equals('NO INTERNET CONNECTION'));
      expect(result.explanation, contains("You're offline"));
      expect(result.explanation, contains('internet connection'));
    });

    test('Section 23 Required Questions: All 12 topics resolve verified official documentation', () {
      final service = VerifiedPythonExplanationService();

      final requiredQuestions = [
        'What is Python?',
        'What is a variable?',
        'What is a list?',
        'What is a tuple?',
        'What is a dictionary?',
        'What is a set?',
        'What does range(5) do?',
        'What is a function?',
        'What is inheritance?',
        'What is a class?',
        'What is an exception?',
        'What is multithreading?',
      ];

      for (final q in requiredQuestions) {
        final result = service.resolveAuthoritativeFallback(q);
        expect(result, isNotNull, reason: 'Failed for question: $q');
        expect(result!.isVerified, isTrue, reason: 'Should be verified for: $q');
        expect(result.sourceUrl, contains('docs.python.org/3'), reason: 'Source must be docs.python.org for: $q');
        expect(result.pythonVersion, equals('Python 3.13'));
        expect(result.explanation.isNotEmpty, isTrue);
      }
    });

    test('Query Normalization cleans raw question variations correctly', () {
      final service = PythonKnowledgeService();

      expect(service.normalizeQuery('What is python?'), equals('python'));
      expect(service.normalizeQuery('what is a variable'), equals('variable'));
      expect(service.normalizeQuery('tell me about multithreading'), equals('multithreading'));
      expect(service.normalizeQuery('what does range(5) do?'), equals('range(5)'));
    });

    test('Verification validates authoritative domain strictly (docs.python.org)', () {
      final service = PythonKnowledgeService();

      final validOfficialSource = {
        'title': 'Python Docs',
        'url': 'https://docs.python.org/3/tutorial/introduction.html',
        'explanation': 'In Python, variables are names that reference values in memory.',
      };
      expect(service.verifySource('variable', validOfficialSource), isTrue);

      final thirdPartySource = {
        'title': 'Random Blog',
        'url': 'https://random-blog.com/python-vars',
        'explanation': 'Variables store values in Python programming.',
      };
      expect(service.verifySource('variable', thirdPartySource), isFalse);
    });

    test('Distinct error states do not blame the internet for search failures (Rule #5 & #18)', () {
      final searchFailed = VerifiedExplanationResult.searchFailed(question: 'test');
      expect(searchFailed.status, equals(VerificationStatus.searchFailed));
      expect(searchFailed.title, equals('SEARCH TEMPORARILY UNAVAILABLE'));
      expect(searchFailed.explanation, isNot(contains('Please check your internet connection')));

      final sourceNotFound = VerifiedExplanationResult.sourceNotFound(question: 'random gibberish xyz');
      expect(sourceNotFound.status, equals(VerificationStatus.sourceNotFound));
      expect(sourceNotFound.title, equals("COULDN'T FIND A RELIABLE SOURCE"));
    });
  });
}
