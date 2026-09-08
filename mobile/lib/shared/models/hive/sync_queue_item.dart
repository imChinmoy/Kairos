import 'package:hive_ce/hive.dart';
import '../../constants/app_constants.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 3)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String entityType; // INVESTIGATION, INSPECTION, OBSERVATION, EVIDENCE

  @HiveField(2)
  late String entityId;

  @HiveField(3)
  late String operation; // CREATE, UPDATE, UPLOAD, DELETE

  @HiveField(4)
  late Map<String, dynamic> payload;

  @HiveField(5)
  late String status; // PENDING, UPLOADING, SYNCED, FAILED, RETRYING

  @HiveField(6)
  int retryCount = 0;

  @HiveField(7)
  DateTime? lastAttemptAt;

  @HiveField(8)
  String? error;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  String? localFilePath; // for UPLOAD operations

  @HiveField(11)
  String? idempotencyKey;
}
