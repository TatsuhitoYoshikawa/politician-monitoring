class Politician {
  final int id;
  final String name;
  final String nameKana;
  final String party;
  final String chamber;
  final String? constituency;
  final String? photoUrl;
  final String? twitterHandle;
  final String? latestActivityDescription;
  final String? latestActivityType;
  final DateTime? latestActivityAt;

  const Politician({
    required this.id,
    required this.name,
    required this.nameKana,
    required this.party,
    required this.chamber,
    this.constituency,
    this.photoUrl,
    this.twitterHandle,
    this.latestActivityDescription,
    this.latestActivityType,
    this.latestActivityAt,
  });

  factory Politician.fromJson(Map<String, dynamic> json) {
    return Politician(
      id:           json['id'] as int,
      name:         json['name'] as String,
      nameKana:     json['name_kana'] as String,
      party:        json['party'] as String,
      chamber:      json['chamber'] as String,
      constituency: json['constituency'] as String?,
      photoUrl:     json['photo_url'] as String?,
      twitterHandle: json['twitter_handle'] as String?,
      latestActivityDescription: json['latest_activity_description'] as String?,
      latestActivityType:        json['latest_activity_type'] as String?,
      latestActivityAt: json['latest_activity_at'] != null
          ? DateTime.parse(json['latest_activity_at'] as String)
          : null,
    );
  }
}
