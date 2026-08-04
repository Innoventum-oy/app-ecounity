import 'package:hive_ce/hive.dart';

part 'pathway_type.g.dart';

@HiveType(typeId: 1204)
enum PathwayType {
  @HiveField(0)
  wiki,
  @HiveField(1)
  quiz,
  @HiveField(2)
  dragdrop,
  @HiveField(3)
  video,
  @HiveField(4)
  slides,
}
