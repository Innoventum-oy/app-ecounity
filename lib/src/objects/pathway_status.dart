import 'package:hive_ce/hive.dart';

part 'pathway_status.g.dart';

@HiveType(typeId: 201)
enum PathwayStatus {
  @HiveField(0)
  opened,
  @HiveField(1)
  completed
}
