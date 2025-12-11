// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineModelAdapter extends TypeAdapter<VaccineModel> {
  @override
  final int typeId = 0;

  @override
  VaccineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineModel(
      id: fields[0] as String,
      vaccineName: fields[1] as String,
      dateGiven: fields[2] as DateTime,
      nextDueDate: fields[3] as DateTime,
      notes: fields[4] as String,
      setReminder: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vaccineName)
      ..writeByte(2)
      ..write(obj.dateGiven)
      ..writeByte(3)
      ..write(obj.nextDueDate)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.setReminder)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
