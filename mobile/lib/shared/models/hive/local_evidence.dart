import 'package:hive_ce/hive.dart';
import '../../constants/app_constants.dart';

part 'local_evidence.g.dart';

@HiveType(typeId: 2)
class LocalEvidence extends HiveObject {
  @HiveField(0)
  late String localId; // UUID generated on device

  @HiveField(1)
  String? serverId; // set after sync

  @HiveField(2)
  late String inspectionId; // local inspection ID

  @HiveField(3)
  String? serverInspectionId;

  @HiveField(4)
  late String fastApiInvestigationId;

  @HiveField(5)
  late String type; // PHOTO, VIDEO, AUDIO, DOCUMENT, OTHER

  @HiveField(6)
  late String localFilePath;

  @HiveField(7)
  late String sha256;

  @HiveField(8)
  late DateTime capturedAt;

  @HiveField(9)
  double? latitude;

  @HiveField(10)
  double? longitude;

  @HiveField(11)
  double? accuracy;

  @HiveField(12)
  late String syncStatus; // LOCAL, UPLOADING, SYNCED, FAILED

  @HiveField(13)
  late String mimeType;

  @HiveField(14)
  late int fileSize;

  @HiveField(15)
  String? fileName;

  @HiveField(16)
  String? idempotencyKey;
}
