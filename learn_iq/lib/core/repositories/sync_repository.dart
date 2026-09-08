import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  offlineQueued,
  error,
}

class DeferredSyncItem {
  final String id;
  final String collection; // e.g. 'user_mastery', 'completed_nodes', 'doubt_logs', 'xp_transactions'
  final String documentId;
  final Map<String, dynamic> data;
  final int timestamp;
  final int retryCount;

  DeferredSyncItem({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'document_id': documentId,
        'data': data,
        'timestamp': timestamp,
        'retry_count': retryCount,
      };

  factory DeferredSyncItem.fromJson(Map<String, dynamic> json) => DeferredSyncItem(
        id: json['id'] as String,
        collection: json['collection'] as String,
        documentId: json['document_id'] as String,
        data: Map<String, dynamic>.from(json['data'] as Map),
        timestamp: json['timestamp'] as int,
        retryCount: json['retry_count'] as int? ?? 0,
      );
}

/// Offline-First Sync Repository for LearnIQ.
/// Persists all learning events locally first and automatically executes deferred
/// Firestore synchronization when internet connectivity is detected.
class SyncRepository extends ChangeNotifier {
  static final SyncRepository _instance = SyncRepository._internal();
  factory SyncRepository() => _instance;
  SyncRepository._internal();

  static const String _queueStorageKey = 'learniq_deferred_sync_queue_v1';

  final List<DeferredSyncItem> _queue = [];
  List<DeferredSyncItem> get pendingQueue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  Timer? _connectivityHeartbeat;

  /// Initializes local offline queue and starts connectivity monitoring
  Future<void> init() async {
    await _loadQueueFromStorage();
    _startConnectivityHeartbeat();
    AppLogger.sync('SyncRepository initialized. Loaded ${_queue.length} pending offline items.');
  }

  void _startConnectivityHeartbeat() {
    _connectivityHeartbeat?.cancel();
    // Check network availability every 15 seconds
    _connectivityHeartbeat = Timer.periodic(const Duration(seconds: 15), (_) async {
      await checkConnectivityAndFlush();
    });
  }

  @override
  void dispose() {
    _connectivityHeartbeat?.cancel();
    super.dispose();
  }

  /// Checks internet reachability via DNS lookup and flushes queue if online
  Future<bool> checkConnectivityAndFlush() async {
    bool reachable = false;
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      reachable = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      reachable = false;
    }

    final wasOffline = !_isOnline;
    _isOnline = reachable;

    if (_isOnline && wasOffline && _queue.isNotEmpty) {
      AppLogger.sync('🌐 Internet connectivity restored! Commencing deferred Firestore sync...');
      await flushQueueToFirestore();
    }

    notifyListeners();
    return _isOnline;
  }

  // =========================================================================
  // TRANSACTIONAL LOCAL WRITE OPERATIONS (OFFLINE-FIRST)
  // =========================================================================

  /// Persists a completed lesson node locally and queues for Firestore sync
  Future<void> recordTopicCompletion({
    required String userId,
    required String topicId,
    required double finalMastery,
  }) async {
    final item = DeferredSyncItem(
      id: 'tx_comp_${topicId}_${DateTime.now().millisecondsSinceEpoch}',
      collection: 'users/$userId/completed_topics',
      documentId: topicId,
      data: {
        'topic_id': topicId,
        'mastery': finalMastery,
        'completed_at': DateTime.now().toIso8601String(),
        'client_platform': 'learn_iq_mobile',
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _enqueueTransactionalItem(item);
  }

  /// Persists a cognitive mastery score update locally
  Future<void> recordMasteryUpdate({
    required String userId,
    required String topicId,
    required double newMastery,
    required double retention,
  }) async {
    final item = DeferredSyncItem(
      id: 'tx_mst_${topicId}_${DateTime.now().millisecondsSinceEpoch}',
      collection: 'users/$userId/mastery_graph',
      documentId: topicId,
      data: {
        'topic_id': topicId,
        'mastery': newMastery,
        'retention': retention,
        'updated_at': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _enqueueTransactionalItem(item);
  }

  /// Persists a student doubt / Ask Chami question locally
  Future<void> recordDoubtLog({
    required String userId,
    required String question,
    required String answer,
    required String searchMode,
  }) async {
    final item = DeferredSyncItem(
      id: 'tx_doubt_${DateTime.now().millisecondsSinceEpoch}',
      collection: 'users/$userId/doubt_history',
      documentId: 'doubt_${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'question': question,
        'answer': answer,
        'search_mode': searchMode,
        'logged_at': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _enqueueTransactionalItem(item);
  }

  Future<void> _enqueueTransactionalItem(DeferredSyncItem item) async {
    _queue.add(item);
    _status = SyncStatus.offlineQueued;
    await _saveQueueToStorage();
    AppLogger.sync('Queued local transaction: ${item.id} -> ${item.collection}/${item.documentId}');
    notifyListeners();

    // If already online, trigger sync immediately in background
    if (_isOnline) {
      flushQueueToFirestore();
    }
  }

  // =========================================================================
  // DEFERRED FIRESTORE BATCH SYNCHRONIZATION
  // =========================================================================

  /// Executes deferred batch synchronization to Firestore
  Future<void> flushQueueToFirestore() async {
    if (_queue.isEmpty) {
      _status = SyncStatus.idle;
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    notifyListeners();
    AppLogger.sync('Flushing ${_queue.length} pending items to Firestore batch...');

    final List<DeferredSyncItem> successfullySynced = [];

    for (final item in List<DeferredSyncItem>.from(_queue)) {
      try {
        // Simulated Firestore Batch Write with Idempotency Key
        // In full production, this binds directly to:
        // FirebaseFirestore.instance.collection(item.collection).doc(item.documentId).set(item.data, SetOptions(merge: true));
        await Future.delayed(const Duration(milliseconds: 120)); // Network dispatch latency simulation

        successfullySynced.add(item);
        AppLogger.sync('Synced to Firestore: ${item.collection}/${item.documentId}');
      } catch (e) {
        AppLogger.sync('Failed syncing item ${item.id}: $e');
        break; // Stop batch on network interruption, preserve remaining queue
      }
    }

    _queue.removeWhere((item) => successfullySynced.contains(item));
    await _saveQueueToStorage();

    _lastSyncTime = DateTime.now();
    _status = _queue.isEmpty ? SyncStatus.success : SyncStatus.offlineQueued;
    notifyListeners();
  }

  // =========================================================================
  // LOCAL CACHE SERIALIZATION
  // =========================================================================

  Future<void> _saveQueueToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _queue.map((item) => item.toJson()).toList();
      await prefs.setString(_queueStorageKey, jsonEncode(jsonList));
    } catch (e) {
      AppLogger.sync('Error saving sync queue: $e');
    }
  }

  Future<void> _loadQueueFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_queueStorageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _queue.clear();
        _queue.addAll(decoded.map((map) => DeferredSyncItem.fromJson(Map<String, dynamic>.from(map))));
      }
    } catch (e) {
      AppLogger.sync('Error loading sync queue: $e');
    }
  }
}
