import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_service.dart';

class InspectionRepository {
  final SyncService _syncService;

  InspectionRepository(this._syncService);

  Future<void> startInspection(String id) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/inspections/$id/start',
    );
  }

  Future<void> recordArrival(String id) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/inspections/$id/arrival',
    );
  }

  Future<void> submitInspection(String id, String finding, String notes, Map<String, dynamic> conditions) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/inspections/$id/submit',
      data: {
        'finding': finding,
        'notes': notes,
        'conditions': conditions,
      },
    );
  }

  Future<void> createObservation(String id, Map<String, dynamic> observationData) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/inspections/$id/observations',
      data: observationData,
    );
  }
}

final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return InspectionRepository(syncService);
});
