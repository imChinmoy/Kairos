// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_evidence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalEvidenceAdapter extends TypeAdapter<LocalEvidence> {
  @override
  final typeId = 2;

  @override
  LocalEvidence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalEvidence()
      ..localId = fields[0] as String
      ..serverId = fields[1] as String?
      ..inspectionId = fields[2] as String
      ..serverInspectionId = fields[3] as String?
      ..fastApiInvestigationId = fields[4] as String
      ..type = fields[5] as String
      ..localFilePath = fields[6] as String
      ..sha256 = fields[7] as String
      ..capturedAt = fields[8] as DateTime
      ..latitude = (fields[9] as num?)?.toDouble()
      ..longitude = (fields[10] as num?)?.toDouble()
      ..accuracy = (fields[11] as num?)?.toDouble()
      ..syncStatus = fields[12] as String
      ..mimeType = fields[13] as String
      ..fileSize = (fields[14] as num).toInt()
      ..fileName = fields[15] as String?
      ..idempotencyKey = fields[16] as String?;
  }

  @override
  void write(BinaryWriter writer, LocalEvidence obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.inspectionId)
      ..writeByte(3)
      ..write(obj.serverInspectionId)
      ..writeByte(4)
      ..write(obj.fastApiInvestigationId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.localFilePath)
      ..writeByte(7)
      ..write(obj.sha256)
      ..writeByte(8)
      ..write(obj.capturedAt)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.accuracy)
      ..writeByte(12)
      ..write(obj.syncStatus)
      ..writeByte(13)
      ..write(obj.mimeType)
      ..writeByte(14)
      ..write(obj.fileSize)
      ..writeByte(15)
      ..write(obj.fileName)
      ..writeByte(16)
      ..write(obj.idempotencyKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalEvidenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
