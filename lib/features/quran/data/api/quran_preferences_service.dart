import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuranPreferencesService {
  static const String _lastSurahKey = 'quran_last_surah';
  static const String _lastAyahKey = 'quran_last_ayah';
  static const String _bookmarksKey = 'quran_bookmarks';

  Future<void> saveLastPosition({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_lastSurahKey, surahNumber);
    await prefs.setInt(_lastAyahKey, ayahNumber);
  }

  Future<Map<String, int>?> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();

    final surah = prefs.getInt(_lastSurahKey);
    final ayah = prefs.getInt(_lastAyahKey);

    if (surah == null || ayah == null) {
      return null;
    }

    return {'surah': surah, 'ayah': ayah};
  }

  Future<List<Map<String, int>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBookmarks = prefs.getStringList(_bookmarksKey) ?? [];

    return savedBookmarks.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;

      return {'surah': decoded['surah'] as int, 'ayah': decoded['ayah'] as int};
    }).toList();
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final bookmarks = await getBookmarks();

    final exists = bookmarks.any(
      (item) => item['surah'] == surahNumber && item['ayah'] == ayahNumber,
    );

    if (exists) return;

    bookmarks.add({'surah': surahNumber, 'ayah': ayahNumber});

    await _saveBookmarks(bookmarks);
  }

  Future<void> removeBookmark({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final bookmarks = await getBookmarks();

    bookmarks.removeWhere(
      (item) => item['surah'] == surahNumber && item['ayah'] == ayahNumber,
    );

    await _saveBookmarks(bookmarks);
  }

  Future<bool> isBookmarked({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final bookmarks = await getBookmarks();

    return bookmarks.any(
      (item) => item['surah'] == surahNumber && item['ayah'] == ayahNumber,
    );
  }

  Future<void> _saveBookmarks(List<Map<String, int>> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = bookmarks.map(jsonEncode).toList();

    await prefs.setStringList(_bookmarksKey, encoded);
  }
}
