class Activity {
  final int id;
  final String activityType;
  final String description;
  final String? sourceUrl;
  final DateTime occurredAt;

  const Activity({
    required this.id,
    required this.activityType,
    required this.description,
    this.sourceUrl,
    required this.occurredAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id:           json['id'] as int,
      activityType: json['activity_type'] as String,
      description:  json['description'] as String,
      sourceUrl:    json['source_url'] as String?,
      occurredAt:   DateTime.parse(json['occurred_at'] as String),
    );
  }
}

class PoliticianDetail {
  final int id;
  final String name;
  final String nameKana;
  final String party;
  final String chamber;
  final String? constituency;
  final String? photoUrl;
  final String? twitterHandle;
  final String? homepageUrl;
  final List<Activity> activities;
  final int totalCount;
  final int totalPages;

  const PoliticianDetail({
    required this.id,
    required this.name,
    required this.nameKana,
    required this.party,
    required this.chamber,
    this.constituency,
    this.photoUrl,
    this.twitterHandle,
    this.homepageUrl,
    required this.activities,
    required this.totalCount,
    required this.totalPages,
  });

  factory PoliticianDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    return PoliticianDetail(
      id:            data['id'] as int,
      name:          data['name'] as String,
      nameKana:      data['name_kana'] as String,
      party:         data['party'] as String,
      chamber:       data['chamber'] as String,
      constituency:  data['constituency'] as String?,
      photoUrl:      data['photo_url'] as String?,
      twitterHandle: data['twitter_handle'] as String?,
      homepageUrl:   data['homepage_url'] as String?,
      activities: (data['activities'] as List<dynamic>)
          .map((a) => Activity.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalCount: meta['total_count'] as int,
      totalPages: meta['total_pages'] as int,
    );
  }
}
