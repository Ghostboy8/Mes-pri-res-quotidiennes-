import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer.dart';

class FavoriteProvider with ChangeNotifier {
  List<Prayer> _favorites = [];
  bool _isLoading = true;

  List<Prayer> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favorites = favoritesList.map((json) => Prayer.fromJson(json)).toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  void addFavorite(Prayer prayer) {
    if (!_favorites.contains(prayer)) {
      _favorites.add(prayer);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(Prayer prayer) {
    if (_favorites.remove(prayer)) {
      _saveFavorites();
      notifyListeners();
    }
  }

  bool isFavorite(Prayer prayer) => _favorites.contains(prayer);

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(_favorites.map((p) => p.toJson()).toList());
    await prefs.setString('favorites', favoritesJson);
  }
}