import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_service.dart';

class SosRepository {
  final SyncService _syncService;

  SosRepository(this._syncService);

  Future<void> triggerSos(double latitude, double longitude) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/sos/trigger',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return SosRepository(syncService);
});
