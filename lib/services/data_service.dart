import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/prayer.dart';
import '../models/rosary.dart';

class DataService {
  Future<List<PrayerCategory>> loadPrayers() async {
    final String jsonString = await rootBundle.loadString('assets/prayers.json');
    final List<dynamic> jsonData = jsonDecode(jsonString)['categories'];
    return jsonData.map((json) => PrayerCategory.fromJson(json)).toList();
  }

  Future<Rosary> loadRosary() async {
    final String jsonString = await rootBundle.loadString('assets/rosary.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return Rosary.fromJson(jsonData);
  }

  Future<List<Prayer>> loadPrayersByCategory(String categoryName) async {
    final List<PrayerCategory> categories = await loadPrayers();
    final category = categories.firstWhere(
          (cat) => cat.nameFr == categoryName,
      orElse: () => PrayerCategory(nameFr: categoryName, nameEn: categoryName, prayers: []),
    );
    return category.prayers;
  }

  Future<List<Prayer>> loadAllPrayers() async {
    final categories = await loadPrayers();
    return categories.expand((cat) => cat.prayers).toList();
  }

  Future<List<RosaryMystery>> loadAllMysteries() async {
    final rosary = await loadRosary();
    return rosary.mysteries.values.expand((mysteries) => mysteries).toList();
  }
}