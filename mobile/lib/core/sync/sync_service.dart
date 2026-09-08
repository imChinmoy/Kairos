import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../network/connectivity_service.dart';
import '../network/dio_client.dart';

class SyncService {
  final Dio _dio;
  final Ref _ref;
  Timer? _timer;
  bool _isSyncing = false;

  SyncService(this._dio, this._ref) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      if (next.valueOrNull == true) {
        _triggerSync();
      }
    });

    // Periodic check
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _triggerSync());
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;
    final isOnline = _ref.read(connectivityProvider).valueOrNull ?? false;
    if (!isOnline) return;

    _isSyncing = true;
    _ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;

    try {
      final box = Hive.box('sync_queue');
      final keys = box.keys.toList();

      if (keys.isEmpty) {
        _ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
        _isSyncing = false;
        return;
      }

      int successCount = 0;

      for (final key in keys) {
        final item = box.get(key) as Map;
        final method = item['method'] as String;
        final path = item['path'] as String;
        final data = item['data'];

        try {
          if (item['isFileUpload'] == true) {
            final filePath = item['data']['filePath'] as String;
            final formData = FormData.fromMap({
              'file': await MultipartFile.fromFile(filePath),
            });
            await _dio.post(path, data: formData);
          } else {
            if (method == 'POST') {
              await _dio.post(path, data: data);
            } else if (method == 'PUT') {
              await _dio.put(path, data: data);
            } else if (method == 'PATCH') {
              await _dio.patch(path, data: data);
            }
          }
          await box.delete(key);
          successCount++;
        } catch (e) {
          // Increment retry count
          final retries = (item['retries'] as int?) ?? 0;
          if (retries > 5) {
            // Drop after 5 retries to avoid blocking queue
            await box.delete(key);
          } else {
            await box.put(key, {...item, 'retries': retries + 1});
          }
        }
      }

      _ref.read(syncStatusProvider.notifier).state = 
          successCount > 0 ? SyncStatus.synced : SyncStatus.error;
          
    } catch (e) {
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
    } finally {
      _isSyncing = false;
      // Reset to idle after a few seconds if it was successful
      if (_ref.read(syncStatusProvider) == SyncStatus.synced) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_ref.read(syncStatusProvider) == SyncStatus.synced) {
            _ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
          }
        });
      }
    }
  }

  Future<void> enqueueRequest({
    required String method,
    required String path,
    dynamic data,
    bool isFileUpload = false,
  }) async {
    final box = Hive.box('sync_queue');
    await box.add({
      'method': method,
      'path': path,
      'data': data,
      'isFileUpload': isFileUpload,
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    });
    
    _ref.read(syncStatusProvider.notifier).state = SyncStatus.pending;
    _triggerSync();
  }
}

enum SyncStatus { idle, pending, syncing, synced, error }

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = DioClient.instance.dio;
  final service = SyncService(dio, ref);
  ref.onDispose(() => service.dispose());
  return service;
});
