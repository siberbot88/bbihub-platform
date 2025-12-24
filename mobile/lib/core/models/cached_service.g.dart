// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedServiceAdapter extends TypeAdapter<CachedService> {
  @override
  final int typeId = 0;

  @override
  CachedService read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedService(
      id: fields[0] as String,
      customerName: fields[1] as String,
      vehiclePlate: fields[2] as String?,
      status: fields[3] as String,
      mechanicName: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      cachedAt: fields[6] as DateTime,
      serviceType: fields[7] as String?,
      estimatedCost: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedService obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.vehiclePlate)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.mechanicName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.cachedAt)
      ..writeByte(7)
      ..write(obj.serviceType)
      ..writeByte(8)
      ..write(obj.estimatedCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
