import 'package:hive_ce/hive.dart';

part 'badge_status_item.g.dart';

@HiveType(typeId: 1206)
class BadgeStatusItem {
  @HiveField(0)
  int? badgeId;
  @HiveField(1)
  bool isNotified;
  @HiveField(2)
  String language;

  BadgeStatusItem({
    required this.badgeId,
    required this.language,
    this.isNotified = false,
  });

  Map<dynamic, dynamic> toJson() {
    return {'badgeId': badgeId, 'isNotified': isNotified, 'language': language};
  }

  @override
  String toString() {
    return 'BadgeStatusItem{badgeId: $badgeId, isNotified: $isNotified, language: $language}';
  }
}
