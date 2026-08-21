class EcoUnityTeacherGroupReport {
  const EcoUnityTeacherGroupReport({
    required this.teacherToken,
    required this.group,
    required this.summary,
    required this.sdgs,
    required this.schemaReady,
    required this.schemaMissing,
    this.lastUpdated,
    this.rawData = const <String, dynamic>{},
  });

  final String teacherToken;
  final EcoUnityTeacherGroupInfo group;
  final EcoUnityTeacherReportSummary summary;
  final List<EcoUnityTeacherSdgStats> sdgs;
  final bool schemaReady;
  final bool schemaMissing;
  final String? lastUpdated;
  final Map<String, dynamic> rawData;

  int get enrolledUsers => summary.enrolledUsers;

  String get displayName => group.displayName(teacherToken);

  EcoUnityTeacherSdgStats? sdgStatsForNumber(int? sdgNumber) {
    if (sdgNumber == null) {
      return null;
    }
    for (final EcoUnityTeacherSdgStats stats in sdgs) {
      if (stats.sdgNumber == sdgNumber) {
        return stats;
      }
    }
    return null;
  }

  EcoUnityTeacherActivityStats? activityStatsFor({
    int? activityId,
    String? slug,
  }) {
    final String normalizedSlug = slug?.trim() ?? '';
    if (activityId != null) {
      for (final EcoUnityTeacherSdgStats sdg in sdgs) {
        for (final EcoUnityTeacherActivityStats stats in sdg.activities) {
          if (stats.activityId == activityId) {
            return stats;
          }
        }
      }
    }
    if (normalizedSlug.isNotEmpty) {
      for (final EcoUnityTeacherSdgStats sdg in sdgs) {
        for (final EcoUnityTeacherActivityStats stats in sdg.activities) {
          if (stats.slug == normalizedSlug) {
            return stats;
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'teacher_token': teacherToken,
      'group': group.toJson(),
      'summary': summary.toJson(),
      'sdgs': sdgs.map((EcoUnityTeacherSdgStats stats) {
        return stats.toJson();
      }).toList(),
      'schemaReady': schemaReady,
      'schemaMissing': schemaMissing,
      if (_hasText(lastUpdated)) 'lastUpdated': lastUpdated,
      if (rawData.isNotEmpty) 'rawData': rawData,
    };
  }

  factory EcoUnityTeacherGroupReport.fromJson(Map<String, dynamic> json) {
    return EcoUnityTeacherGroupReport(
      teacherToken: _readString(
        json['teacher_token'] ?? json['teacherToken'] ?? json['token'],
      ),
      group: EcoUnityTeacherGroupInfo.fromJson(_readMap(json['group'])),
      summary: EcoUnityTeacherReportSummary.fromJson(_readMap(json['summary'])),
      sdgs: _readMapList(
        json['sdgs'],
      ).map(EcoUnityTeacherSdgStats.fromJson).toList(),
      schemaReady: _readBool(json['schemaReady'] ?? json['schema_ready']),
      schemaMissing: _readBool(json['schemaMissing'] ?? json['schema_missing']),
      lastUpdated: _readOptionalString(
        json['lastUpdated'] ?? json['last_updated'],
      ),
      rawData:
          _readMap(json['rawData'] ?? json['raw_data']) ??
          const <String, dynamic>{},
    );
  }

  factory EcoUnityTeacherGroupReport.fromApiResponse(
    Map<String, dynamic> response, {
    required String teacherToken,
  }) {
    final Map<String, dynamic> report =
        _readMap(response['report']) ?? _readMap(response['data']) ?? response;
    return EcoUnityTeacherGroupReport(
      teacherToken: teacherToken,
      group: EcoUnityTeacherGroupInfo.fromJson(_readMap(report['group'])),
      summary: EcoUnityTeacherReportSummary.fromJson(
        _readMap(report['summary']),
      ),
      sdgs: _readMapList(
        report['sdgs'],
      ).map(EcoUnityTeacherSdgStats.fromJson).toList(),
      schemaReady: _readBool(report['schemaReady'] ?? report['schema_ready']),
      schemaMissing: _readBool(
        report['schemaMissing'] ?? report['schema_missing'],
      ),
      lastUpdated: _readOptionalString(
        report['lastUpdated'] ?? report['last_updated'],
      ),
      rawData: report,
    );
  }
}

class EcoUnityTeacherGroupInfo {
  const EcoUnityTeacherGroupInfo({
    this.id,
    this.groupKey,
    this.pilotKey,
    this.name,
    this.country,
    this.language,
    this.status,
  });

  final int? id;
  final String? groupKey;
  final String? pilotKey;
  final String? name;
  final String? country;
  final String? language;
  final String? status;

  String displayName(String fallback) {
    return _firstText(<String?>[name, groupKey, pilotKey, fallback]) ??
        fallback;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (_hasText(groupKey)) 'group_key': groupKey,
      if (_hasText(pilotKey)) 'pilot_key': pilotKey,
      if (_hasText(name)) 'name': name,
      if (_hasText(country)) 'country': country,
      if (_hasText(language)) 'language': language,
      if (_hasText(status)) 'status': status,
    };
  }

  factory EcoUnityTeacherGroupInfo.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> data = json ?? const <String, dynamic>{};
    return EcoUnityTeacherGroupInfo(
      id: _readInt(data['id']),
      groupKey: _readOptionalString(data['group_key']),
      pilotKey: _readOptionalString(data['pilot_key']),
      name: _readOptionalString(data['name']),
      country: _readOptionalString(data['country']),
      language: _readOptionalString(data['language']),
      status: _readOptionalString(data['status']),
    );
  }
}

class EcoUnityTeacherReportSummary {
  const EcoUnityTeacherReportSummary({
    required this.enrolledUsers,
    required this.participantCodeRows,
    required this.activeUsers,
    required this.sessions,
    required this.events,
    required this.activityOpenedUsers,
    required this.activityCompletedUsers,
    this.activityCompletionRate,
  });

  final int enrolledUsers;
  final int participantCodeRows;
  final int activeUsers;
  final int sessions;
  final int events;
  final int activityOpenedUsers;
  final int activityCompletedUsers;
  final double? activityCompletionRate;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'enrolled_users': enrolledUsers,
      'participant_code_rows': participantCodeRows,
      'active_users': activeUsers,
      'sessions': sessions,
      'events': events,
      'activity_opened_users': activityOpenedUsers,
      'activity_completed_users': activityCompletedUsers,
      if (activityCompletionRate != null)
        'activity_completion_rate': activityCompletionRate,
    };
  }

  factory EcoUnityTeacherReportSummary.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> data = json ?? const <String, dynamic>{};
    return EcoUnityTeacherReportSummary(
      enrolledUsers: _readInt(data['enrolled_users']) ?? 0,
      participantCodeRows: _readInt(data['participant_code_rows']) ?? 0,
      activeUsers: _readInt(data['active_users']) ?? 0,
      sessions: _readInt(data['sessions']) ?? 0,
      events: _readInt(data['events']) ?? 0,
      activityOpenedUsers: _readInt(data['activity_opened_users']) ?? 0,
      activityCompletedUsers: _readInt(data['activity_completed_users']) ?? 0,
      activityCompletionRate: _readDouble(data['activity_completion_rate']),
    );
  }
}

class EcoUnityTeacherSdgStats {
  const EcoUnityTeacherSdgStats({
    required this.sdgNumber,
    required this.moduleOpenedUsers,
    required this.moduleCompletedUsers,
    required this.activityOpenedUsers,
    required this.activityCompletedUsers,
    required this.activities,
    this.activityCompletionRate,
  });

  final int? sdgNumber;
  final int moduleOpenedUsers;
  final int moduleCompletedUsers;
  final int activityOpenedUsers;
  final int activityCompletedUsers;
  final double? activityCompletionRate;
  final List<EcoUnityTeacherActivityStats> activities;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (sdgNumber != null) 'sdg_number': sdgNumber,
      'module_opened_users': moduleOpenedUsers,
      'module_completed_users': moduleCompletedUsers,
      'activity_opened_users': activityOpenedUsers,
      'activity_completed_users': activityCompletedUsers,
      if (activityCompletionRate != null)
        'activity_completion_rate': activityCompletionRate,
      'activities': activities.map((EcoUnityTeacherActivityStats stats) {
        return stats.toJson();
      }).toList(),
    };
  }

  factory EcoUnityTeacherSdgStats.fromJson(Map<String, dynamic> json) {
    return EcoUnityTeacherSdgStats(
      sdgNumber: _readInt(json['sdg_number'] ?? json['sdg']),
      moduleOpenedUsers: _readInt(json['module_opened_users']) ?? 0,
      moduleCompletedUsers: _readInt(json['module_completed_users']) ?? 0,
      activityOpenedUsers: _readInt(json['activity_opened_users']) ?? 0,
      activityCompletedUsers: _readInt(json['activity_completed_users']) ?? 0,
      activityCompletionRate: _readDouble(json['activity_completion_rate']),
      activities: _readMapList(
        json['activities'],
      ).map(EcoUnityTeacherActivityStats.fromJson).toList(),
    );
  }
}

class EcoUnityTeacherActivityStats {
  const EcoUnityTeacherActivityStats({
    required this.openedUsers,
    required this.completedUsers,
    this.activityId,
    this.sdgNumber,
    this.activityType,
    this.title,
    this.slug,
    this.completionRate,
    this.averageScore,
    this.maxScore,
  });

  final int? activityId;
  final int? sdgNumber;
  final String? activityType;
  final String? title;
  final String? slug;
  final int openedUsers;
  final int completedUsers;
  final double? completionRate;
  final double? averageScore;
  final double? maxScore;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (activityId != null) 'activity_id': activityId,
      if (sdgNumber != null) 'sdg_number': sdgNumber,
      if (_hasText(activityType)) 'activity_type': activityType,
      if (_hasText(title)) 'title': title,
      if (_hasText(slug)) 'slug': slug,
      'opened_users': openedUsers,
      'completed_users': completedUsers,
      if (completionRate != null) 'completion_rate': completionRate,
      if (averageScore != null) 'average_score': averageScore,
      if (maxScore != null) 'max_score': maxScore,
    };
  }

  factory EcoUnityTeacherActivityStats.fromJson(Map<String, dynamic> json) {
    return EcoUnityTeacherActivityStats(
      activityId: _readInt(
        json['activity_id'] ?? json['activityId'] ?? json['id'],
      ),
      sdgNumber: _readInt(json['sdg_number'] ?? json['sdg']),
      activityType: _readOptionalString(json['activity_type']),
      title: _readOptionalString(json['title']),
      slug: _readOptionalString(json['slug'] ?? json['activity_key']),
      openedUsers: _readInt(json['opened_users']) ?? 0,
      completedUsers: _readInt(json['completed_users']) ?? 0,
      completionRate: _readDouble(json['completion_rate']),
      averageScore: _readDouble(
        json['average_score'] ??
            json['avg_score'] ??
            json['quiz_average_score'] ??
            json['average_quiz_score'] ??
            json['score_average'],
      ),
      maxScore: _readDouble(
        json['max_score'] ?? json['maximum_score'] ?? json['possible_score'],
      ),
    );
  }
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<Map<String, dynamic>> _readMapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value.whereType<Map>().map((Map item) {
    return Map<String, dynamic>.from(item);
  }).toList();
}

String _readString(Object? value) {
  return _readOptionalString(value) ?? '';
}

String? _readOptionalString(Object? value) {
  final String? text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  final String? text = _readOptionalString(value);
  if (text == null) {
    return null;
  }
  return double.tryParse(text);
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

String? _firstText(Iterable<String?> values) {
  for (final String? value in values) {
    if (_hasText(value)) {
      return value!.trim();
    }
  }
  return null;
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}
