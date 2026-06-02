import 'package:hive_ce/hive.dart';
import 'package:ecounity/src/objects/pathway_status.dart';

part 'pathway_status_item.g.dart';

@HiveType(typeId: 202)
class PathwayStatusItem {
  @HiveField(0)
  int id;
  @HiveField(1)
  PathwayStatus status;

  PathwayStatusItem({required this.id, required this.status});

  PathwayStatusItem fromJson(Map<dynamic, dynamic> response) {
    return PathwayStatusItem(id: response['id'], status: response['status']);
  }

  Map<dynamic, dynamic> toJson() {
    return {'id': id, 'status': status};
  }

  @override
  String toString() {
    return 'PathwayStatusItem{id: $id, status: $status}';
  }
}
