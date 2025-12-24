// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_dashboard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedDashboardAdapter extends TypeAdapter<CachedDashboard> {
  @override
  final int typeId = 1;

  @override
  CachedDashboard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedDashboard(
      servicesToday: fields[0] as int,
      inProgress: fields[1] as int,
      completed: fields[2] as int,
      todayRevenue: fields[3] as double?,
      cachedAt: fields[4] as DateTime,
      mechanicStats: (fields[5] as List?)?.cast<CachedMechanicStat>(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedDashboard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.servicesToday)
      ..writeByte(1)
      ..write(obj.inProgress)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.todayRevenue)
      ..writeByte(4)
      ..write(obj.cachedAt)
      ..writeByte(5)
      ..write(obj.mechanicStats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedDashboardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedMechanicStatAdapter extends TypeAdapter<CachedMechanicStat> {
  @override
  final int typeId = 2;

  @override
  CachedMechanicStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedMechanicStat(
      id: fields[0] as String,
      name: fields[1] as String,
      completedJobs: fields[2] as int,
      activeJobs: fields[3] as int,
      avgRating: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMechanicStat obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.completedJobs)
      ..writeByte(3)
      ..write(obj.activeJobs)
      ..writeByte(4)
      ..write(obj.avgRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedMechanicStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
