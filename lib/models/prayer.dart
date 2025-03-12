class Prayer {
  final String titleFr;
  final String titleEn;
  final String textFr;
  final String textEn;

  Prayer({
    required this.titleFr,
    required this.titleEn,
    required this.textFr,
    required this.textEn,
  });

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      titleFr: json['titleFr'],
      titleEn: json['titleEn'],
      textFr: json['textFr'],
      textEn: json['textEn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleFr': titleFr,
      'titleEn': titleEn,
      'textFr': textFr,
      'textEn': textEn,
    };
  }

  String getTitle(String lang) => lang == 'fr' ? titleFr : titleEn;
  String getText(String lang) => lang == 'fr' ? textFr : textEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Prayer &&
              runtimeType == other.runtimeType &&
              titleFr == other.titleFr &&
              titleEn == other.titleEn &&
              textFr == other.textFr &&
              textEn == other.textEn;

  @override
  int get hashCode => titleFr.hashCode ^ titleEn.hashCode ^ textFr.hashCode ^ textEn.hashCode;
}

class PrayerCategory {
  final String nameFr;
  final String nameEn;
  final List<Prayer> prayers;

  PrayerCategory({
    required this.nameFr,
    required this.nameEn,
    required this.prayers,
  });

  factory PrayerCategory.fromJson(Map<String, dynamic> json) {
    return PrayerCategory(
      nameFr: json['nameFr'],
      nameEn: json['nameEn'],
      prayers: (json['prayers'] as List).map((p) => Prayer.fromJson(p)).toList(),
    );
  }

  String getName(String lang) => lang == 'fr' ? nameFr : nameEn;
}