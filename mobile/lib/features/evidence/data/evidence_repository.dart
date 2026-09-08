import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_service.dart';

class EvidenceRepository {
  final SyncService _syncService;

  EvidenceRepository(this._syncService);

  Future<void> uploadEvidence(String inspectionId, String filePath) async {
    await _syncService.enqueueRequest(
      method: 'POST',
      path: '/inspections/$inspectionId/evidence',
      data: {'filePath': filePath},
      isFileUpload: true,
    );
  }
}

final evidenceRepositoryProvider = Provider<EvidenceRepository>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return EvidenceRepository(syncService);
});
