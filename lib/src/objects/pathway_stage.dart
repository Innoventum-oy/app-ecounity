import 'package:hive_ce/hive.dart';

part 'pathway_stage.g.dart';

@HiveType(typeId: 203)
enum PathwayStage {
  @HiveField(0)
  any,
  @HiveField(1)
  before,
  @HiveField(2)
  during,
  @HiveField(3)
  after
}
