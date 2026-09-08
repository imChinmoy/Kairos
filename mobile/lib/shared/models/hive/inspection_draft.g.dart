// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionDraftAdapter extends TypeAdapter<InspectionDraft> {
  @override
  final typeId = 1;

  @override
  InspectionDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionDraft()
      ..localId = fields[0] as String
      ..serverId = fields[1] as String?
      ..fastApiInvestigationId = fields[2] as String
      ..officerId = fields[3] as String
      ..status = fields[4] as String
      ..startedAt = fields[5] as DateTime?
      ..submittedAt = fields[6] as DateTime?
      ..arrivalLatitude = (fields[7] as num?)?.toDouble()
      ..arrivalLongitude = (fields[8] as num?)?.toDouble()
      ..arrivalAccuracy = (fields[9] as num?)?.toDouble()
      ..arrivalTimestamp = fields[10] as DateTime?
      ..notes = fields[11] as String?
      ..finding = fields[12] as String?
      ..createdAt = fields[13] as DateTime
      ..updatedAt = fields[14] as DateTime?
      ..siteConditions = (fields[15] as Map?)?.cast<String, dynamic>()
      ..oilObservation = (fields[16] as Map?)?.cast<String, dynamic>()
      ..idempotencyKey = fields[17] as String?
      ..isSynced = fields[18] as bool;
  }

  @override
  void write(BinaryWriter writer, InspectionDraft obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.fastApiInvestigationId)
      ..writeByte(3)
      ..write(obj.officerId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.submittedAt)
      ..writeByte(7)
      ..write(obj.arrivalLatitude)
      ..writeByte(8)
      ..write(obj.arrivalLongitude)
      ..writeByte(9)
      ..write(obj.arrivalAccuracy)
      ..writeByte(10)
      ..write(obj.arrivalTimestamp)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.finding)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.siteConditions)
      ..writeByte(16)
      ..write(obj.oilObservation)
      ..writeByte(17)
      ..write(obj.idempotencyKey)
      ..writeByte(18)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
