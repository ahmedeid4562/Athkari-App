import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../azkar/data/model/azkar_model.dart';

class FavoritesLocalData {
  static const String _favoritesKey = 'favorite_azkar';

  Future<List<AzkarModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.map((item) {
      final Map<String, dynamic> json = jsonDecode(item);
      return AzkarModel.fromJson(json);
    }).toList();
  }

  Future<void> addFavorite(AzkarModel azkar) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    final alreadyExists = favorites.any((item) {
      final Map<String, dynamic> json = jsonDecode(item);

      return json['text'] == azkar.text &&
          json['reference'] == azkar.reference;
    });

    if (alreadyExists) return;

    favorites.add(
      jsonEncode({
        'id': azkar.id,
        'text': azkar.text,
        'repeat': azkar.repeat,
        'reference': azkar.reference,
      }),
    );

    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<void> removeFavorite(AzkarModel azkar) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    favorites.removeWhere((item) {
      final Map<String, dynamic> json = jsonDecode(item);

      return json['text'] == azkar.text &&
          json['reference'] == azkar.reference;
    });

    await prefs.setStringList(_favoritesKey, favorites);
  }
}