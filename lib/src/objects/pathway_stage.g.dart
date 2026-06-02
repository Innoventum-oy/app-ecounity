// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathway_stage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PathwayStageAdapter extends TypeAdapter<PathwayStage> {
  @override
  final typeId = 203;

  @override
  PathwayStage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PathwayStage.any;
      case 1:
        return PathwayStage.before;
      case 2:
        return PathwayStage.during;
      case 3:
        return PathwayStage.after;
      default:
        return PathwayStage.any;
    }
  }

  @override
  void write(BinaryWriter writer, PathwayStage obj) {
    switch (obj) {
      case PathwayStage.any:
        writer.writeByte(0);
      case PathwayStage.before:
        writer.writeByte(1);
      case PathwayStage.during:
        writer.writeByte(2);
      case PathwayStage.after:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathwayStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
