// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedStaffAdapter extends TypeAdapter<CachedStaff> {
  @override
  final int typeId = 3;

  @override
  CachedStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedStaff(
      id: fields[0] as String,
      userName: fields[1] as String,
      userEmail: fields[2] as String?,
      role: fields[3] as String,
      status: fields[4] as String,
      cachedAt: fields[5] as DateTime,
      completedJobs: fields[6] as int?,
      activeJobs: fields[7] as int?,
      avgRating: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedStaff obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.userEmail)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.cachedAt)
      ..writeByte(6)
      ..write(obj.completedJobs)
      ..writeByte(7)
      ..write(obj.activeJobs)
      ..writeByte(8)
      ..write(obj.avgRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
