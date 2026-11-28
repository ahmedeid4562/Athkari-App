import 'package:flutter/material.dart';

import '../../data/api/quran_preferences_service.dart';
import '../../data/model/quran_surah_model.dart';
import 'quran_reading_screen.dart';

class QuranBookmarksScreen extends StatefulWidget {
  final List<QuranSurahModel> surahs;

  const QuranBookmarksScreen({super.key, required this.surahs});

  @override
  State<QuranBookmarksScreen> createState() => _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends State<QuranBookmarksScreen> {
  final QuranPreferencesService _preferencesService = QuranPreferencesService();

  late Future<List<Map<String, int>>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _bookmarksFuture = _preferencesService.getBookmarks();
  }

  String _toArabicNumbers(int number) {
    const numbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    return number
        .toString()
        .split('')
        .map((digit) => numbers[int.parse(digit)])
        .join();
  }

  Future<void> _removeBookmark(int surahNumber, int ayahNumber) async {
    await _preferencesService.removeBookmark(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (!mounted) return;

    setState(_loadBookmarks);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الآية من المحفوظات')));
  }

  void _openAyah(int surahIndex, int ayahNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReadingScreen(
          surahs: widget.surahs,
          initialIndex: surahIndex,
          initialAyah: ayahNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الآيات المحفوظة'), centerTitle: true),
      body: FutureBuilder<List<Map<String, int>>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('حدث خطأ أثناء تحميل الآيات المحفوظة'),
            );
          }

          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 75,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد آيات محفوظة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أثناء قراءة القرآن اضغط على زر حفظ الآية لتجدها هنا.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmarks_rounded,
                        size: 35,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الآيات التي حفظتها',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('عدد الآيات: ${bookmarks.length}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final surahNumber = bookmark['surah']!;
                    final ayahNumber = bookmark['ayah']!;

                    final surahIndex = widget.surahs.indexWhere(
                      (surah) => surah.number == surahNumber,
                    );

                    if (surahIndex == -1) {
                      return const SizedBox.shrink();
                    }

                    final surah = widget.surahs[surahIndex];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    _toArabicNumbers(surahNumber),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'سورة ${surah.name}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'الآية رقم ${_toArabicNumbers(ayahNumber)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _openAyah(surahIndex, ayahNumber);
                                },
                                icon: const Icon(Icons.menu_book_rounded),
                                label: const Text('افتح الآية'),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () {
                                  _removeBookmark(surahNumber, ayahNumber);
                                },
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('حذف من المحفوظات'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
