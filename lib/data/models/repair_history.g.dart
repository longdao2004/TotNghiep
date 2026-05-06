// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepairHistoryAdapter extends TypeAdapter<RepairHistory> {
  @override
  final int typeId = 1;

  @override
  RepairHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepairHistory(
      id: fields[0] as String,
      deviceId: fields[1] as String,
      date: fields[2] as DateTime,
      issue: fields[3] as String,
      cost: fields[4] as double,
      aiDiagnosisNote: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RepairHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.issue)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.aiDiagnosisNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
