import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_models.dart';
import '../data/python_curriculum_data.dart';
import '../services/api_service.dart';
import '../utils/app_logger.dart';

class LearningRepository {
  static final LearningRepository _instance = LearningRepository._internal();
  factory LearningRepository() => _instance;
  LearningRepository._internal();

  final List<SyncEvent> _eventQueue = [];
  List<SyncEvent> get eventQueue => List.unmodifiable(_eventQueue);

  List<CurriculumItem> get _curriculumIndex {
    return PythonCurriculumData.allUnits.map((u) {
      return CurriculumItem(
        id: u.id,
        title: u.title,
        category: u.unitTitle,
        description: '${u.storyTheme}: ${u.scenes.first.narrative}',
        keywords: [...u.keywords, u.storyTheme.toLowerCase(), u.unitTitle.toLowerCase()],
      );
    }).toList();
  }

  /// Fast local search with sub-word matching and ranking (0ms latency, zero network)
  List<CurriculumItem> searchCurriculum(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return _curriculumIndex;

    AppLogger.course('Searching local curriculum index for: "$cleanQuery"');

    final results = _curriculumIndex.where((item) {
      if (item.title.toLowerCase().contains(cleanQuery)) return true;
      if (item.category.toLowerCase().contains(cleanQuery)) return true;
      if (item.description.toLowerCase().contains(cleanQuery)) return true;
      return item.keywords.any((kw) => kw.contains(cleanQuery) || cleanQuery.contains(kw));
    }).toList();

    // Sort exact matches higher
    results.sort((a, b) {
      final aExact = a.title.toLowerCase().startsWith(cleanQuery);
      final bExact = b.title.toLowerCase().startsWith(cleanQuery);
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      return 0;
    });

    return results;
  }

  /// Enqueue an event locally and persist for idempotent offline synchronization
  Future<void> enqueueEvent({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final eventId = 'evt_${DateTime.now().millisecondsSinceEpoch}_${payload['exercise_id'] ?? payload['node_id'] ?? ''}';
    final event = SyncEvent(
      id: eventId,
      type: type,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isSynced: false,
    );

    _eventQueue.add(event);
    AppLogger.sync('Enqueued offline event: $type ($eventId). Pending count: ${_eventQueue.length}');

    await _persistEventQueue();

    // Trigger silent background flush
    flushPendingEvents();
  }

  /// Silently flush pending unsynced events in background
  void flushPendingEvents() {
    final pending = _eventQueue.where((e) => !e.isSynced).toList();
    if (pending.isEmpty) return;

    for (final event in pending) {
      ApiService.syncEventInBackground(event.toJson());
    }
  }

  Future<void> loadPersistedQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('offline_event_queue');
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw);
        _eventQueue.clear();
        for (final item in list) {
          _eventQueue.add(SyncEvent.fromJson(item));
        }
        AppLogger.sync('Restored ${_eventQueue.length} events from local storage');
      }
    } catch (e) {
      AppLogger.sync('Error reading offline queue: $e');
    }
  }

  Future<void> _persistEventQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _eventQueue.map((e) => e.toJson()).toList();
      await prefs.setString('offline_event_queue', jsonEncode(jsonList));
    } catch (e) {
      AppLogger.sync('Error writing offline queue: $e');
    }
  }
}
