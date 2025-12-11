// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 1;

  @override
  PetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      breed: fields[3] as String,
      gender: fields[4] as String,
      dateOfBirth: fields[5] as DateTime,
      weight: fields[6] as double,
      notes: fields[7] as String,
      imagePath: fields[8] as String?,
      vaccines: (fields[9] as List).cast<VaccineModel>(),
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.dateOfBirth)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.vaccines)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PetModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
