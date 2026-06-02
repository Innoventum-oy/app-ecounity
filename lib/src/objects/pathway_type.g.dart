// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathway_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PathwayTypeAdapter extends TypeAdapter<PathwayType> {
  @override
  final typeId = 204;

  @override
  PathwayType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PathwayType.wiki;
      case 1:
        return PathwayType.quiz;
      case 2:
        return PathwayType.dragdrop;
      case 3:
        return PathwayType.video;
      case 4:
        return PathwayType.slides;
      default:
        return PathwayType.wiki;
    }
  }

  @override
  void write(BinaryWriter writer, PathwayType obj) {
    switch (obj) {
      case PathwayType.wiki:
        writer.writeByte(0);
      case PathwayType.quiz:
        writer.writeByte(1);
      case PathwayType.dragdrop:
        writer.writeByte(2);
      case PathwayType.video:
        writer.writeByte(3);
      case PathwayType.slides:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathwayTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
