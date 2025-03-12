class RosaryMystery {
  final String nameFr;
  final String nameEn;
  final String meditationFr;
  final String meditationEn;

  RosaryMystery({
    required this.nameFr,
    required this.nameEn,
    required this.meditationFr,
    required this.meditationEn,
  });

  factory RosaryMystery.fromJson(Map<String, dynamic> json) {
    return RosaryMystery(
      nameFr: json['nameFr'],
      nameEn: json['nameEn'],
      meditationFr: json['meditationFr'],
      meditationEn: json['meditationEn'],
    );
  }

  String getName(String lang) => lang == 'fr' ? nameFr : nameEn;
  String getMeditation(String lang) => lang == 'fr' ? meditationFr : meditationEn;
}

class Rosary {
  final Map<String, List<RosaryMystery>> mysteries;

  Rosary({required this.mysteries});

  factory Rosary.fromJson(Map<String, dynamic> json) {
    Map<String, List<RosaryMystery>> mysteries = {};
    json['mysteries'].forEach((key, value) {
      mysteries[key] = (value as List).map((m) => RosaryMystery.fromJson(m)).toList();
    });
    return Rosary(mysteries: mysteries);
  }
}