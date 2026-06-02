// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathway_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PathwayStatusAdapter extends TypeAdapter<PathwayStatus> {
  @override
  final typeId = 201;

  @override
  PathwayStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PathwayStatus.opened;
      case 1:
        return PathwayStatus.completed;
      default:
        return PathwayStatus.opened;
    }
  }

  @override
  void write(BinaryWriter writer, PathwayStatus obj) {
    switch (obj) {
      case PathwayStatus.opened:
        writer.writeByte(0);
      case PathwayStatus.completed:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathwayStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
