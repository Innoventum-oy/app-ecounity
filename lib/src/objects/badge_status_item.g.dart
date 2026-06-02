// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_status_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeStatusItemAdapter extends TypeAdapter<BadgeStatusItem> {
  @override
  final typeId = 206;

  @override
  BadgeStatusItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeStatusItem(
      badgeId: (fields[0] as num?)?.toInt(),
      language: fields[2] as String,
      isNotified: fields[1] == null ? false : fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeStatusItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.badgeId)
      ..writeByte(1)
      ..write(obj.isNotified)
      ..writeByte(2)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeStatusItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
