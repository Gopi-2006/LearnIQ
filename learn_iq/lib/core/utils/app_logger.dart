import 'package:flutter/foundation.dart';

/// Structured developer logging for LearnIQ
/// Categories: [AUTH], [COURSE], [LESSON], [FIREBASE], [AI], [NAVIGATION], [CAMERA], [MIC], [SYNC]
class AppLogger {
  static void auth(String message) => _log('AUTH', message);
  static void course(String message) => _log('COURSE', message);
  static void lesson(String message) => _log('LESSON', message);
  static void firebase(String message) => _log('FIREBASE', message);
  static void ai(String message) => _log('AI', message);
  static void nav(String message) => _log('NAVIGATION', message);
  static void camera(String message) => _log('CAMERA', message);
  static void mic(String message) => _log('MIC', message);
  static void sync(String message) => _log('SYNC', message);

  static void _log(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }
}
