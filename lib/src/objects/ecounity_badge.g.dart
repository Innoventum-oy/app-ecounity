// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecounity_badge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EcoUnityBadgeAdapter extends TypeAdapter<EcoUnityBadge> {
  @override
  final typeId = 1205;

  @override
  EcoUnityBadge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EcoUnityBadge(
        id: (fields[0] as num?)?.toInt(),
        name: fields[1] as String?,
        description: fields[2] as String?,
        badgeimageurl: fields[3] as String?,
        color: fields[6] as String?,
        accesslevel: fields[101] == null ? 0 : (fields[101] as num).toInt(),
        requiredPathways: (fields[7] as List?)?.cast<core.WebPage>(),
        pathway: fields[251] as String?,
        data: (fields[100] as Map?)?.cast<dynamic, dynamic>(),
      )
      ..assertionBakedBadgeImageUrl = fields[4] as String?
      ..assertionCertificateAsPdfUrl = fields[5] as String?
      ..loaded = fields[102] as bool
      ..isNotified = fields[252] as bool;
  }

  @override
  void write(BinaryWriter writer, EcoUnityBadge obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.badgeimageurl)
      ..writeByte(4)
      ..write(obj.assertionBakedBadgeImageUrl)
      ..writeByte(5)
      ..write(obj.assertionCertificateAsPdfUrl)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.requiredPathways)
      ..writeByte(100)
      ..write(obj.data)
      ..writeByte(101)
      ..write(obj.accesslevel)
      ..writeByte(102)
      ..write(obj.loaded)
      ..writeByte(251)
      ..write(obj.pathway)
      ..writeByte(252)
      ..write(obj.isNotified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EcoUnityBadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
