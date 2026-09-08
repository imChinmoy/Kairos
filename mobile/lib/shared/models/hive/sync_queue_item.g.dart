// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final typeId = 3;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem()
      ..id = fields[0] as String
      ..entityType = fields[1] as String
      ..entityId = fields[2] as String
      ..operation = fields[3] as String
      ..payload = (fields[4] as Map).cast<String, dynamic>()
      ..status = fields[5] as String
      ..retryCount = (fields[6] as num).toInt()
      ..lastAttemptAt = fields[7] as DateTime?
      ..error = fields[8] as String?
      ..createdAt = fields[9] as DateTime
      ..localFilePath = fields[10] as String?
      ..idempotencyKey = fields[11] as String?;
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.operation)
      ..writeByte(4)
      ..write(obj.payload)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.lastAttemptAt)
      ..writeByte(8)
      ..write(obj.error)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.localFilePath)
      ..writeByte(11)
      ..write(obj.idempotencyKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
