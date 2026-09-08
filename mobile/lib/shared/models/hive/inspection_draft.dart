import 'package:hive_ce/hive.dart';
import '../../constants/app_constants.dart';

part 'inspection_draft.g.dart';

@HiveType(typeId: 1)
class InspectionDraft extends HiveObject {
  @HiveField(0)
  late String localId;

  @HiveField(1)
  String? serverId;

  @HiveField(2)
  late String fastApiInvestigationId;

  @HiveField(3)
  late String officerId;

  @HiveField(4)
  late String status; // NOT_STARTED, IN_PROGRESS, DRAFT, SUBMITTED, SYNCED

  @HiveField(5)
  DateTime? startedAt;

  @HiveField(6)
  DateTime? submittedAt;

  @HiveField(7)
  double? arrivalLatitude;

  @HiveField(8)
  double? arrivalLongitude;

  @HiveField(9)
  double? arrivalAccuracy;

  @HiveField(10)
  DateTime? arrivalTimestamp;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  String? finding;

  @HiveField(13)
  late DateTime createdAt;

  @HiveField(14)
  DateTime? updatedAt;

  @HiveField(15)
  Map<String, dynamic>? siteConditions;

  @HiveField(16)
  Map<String, dynamic>? oilObservation;

  @HiveField(17)
  String? idempotencyKey;

  @HiveField(18)
  bool isSynced = false;
}
