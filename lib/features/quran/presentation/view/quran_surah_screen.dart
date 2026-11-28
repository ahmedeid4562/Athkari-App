import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/quran_local_data.dart';
import '../../data/api/quran_preferences_service.dart';
import '../../data/model/quran_surah_model.dart';
import '../view_model/quran_cubit.dart';
import 'quran_bookmarks_screen.dart';
import 'quran_partition_screen.dart';
import 'quran_reading_screen.dart';

class QuranSurahScreen extends StatefulWidget {
  const QuranSurahScreen({super.key});

  @override
  State<QuranSurahScreen> createState() => _QuranSurahScreenState();
}

class _QuranSurahScreenState extends State<QuranSurahScreen> {
  final TextEditingController _searchController = TextEditingController();
  final QuranPreferencesService _preferencesService = QuranPreferencesService();

  late Future<Map<String, int>?> _lastPositionFuture;

  String searchQuery = '';
  bool _hasCheckedInitialPosition = false;

  @override
  void initState() {
    super.initState();
    _lastPositionFuture = _preferencesService.getLastPosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshLastPosition() async {
    final position = await _preferencesService.getLastPosition();

    if (!mounted) return;

    setState(() {
      _lastPositionFuture = Future.value(position);
    });
  }

  void _openLastPositionIfAvailable(List<QuranSurahModel> surahs) {
    if (_hasCheckedInitialPosition) return;

    _hasCheckedInitialPosition = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final position = await _preferencesService.getLastPosition();

      if (!mounted || position == null) return;

      final surahIndex = surahs.indexWhere(
        (surah) => surah.number == position['surah'],
      );

      if (surahIndex == -1) return;

      final ayahNumber = position['ayah'] ?? 1;

      if (ayahNumber < 1 || ayahNumber > surahs[surahIndex].ayahCount) {
        return;
      }

      await _openReading(
        surahs: surahs,
        surahIndex: surahIndex,
        ayahNumber: ayahNumber,
      );
    });
  }

  Future<void> _openReading({
    required List<QuranSurahModel> surahs,
    required int surahIndex,
    int? ayahNumber,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReadingScreen(
          surahs: surahs,
          initialIndex: surahIndex,
          initialAyah: ayahNumber,
        ),
      ),
    );

    await _refreshLastPosition();
  }

  Future<void> _openBookmarks(List<QuranSurahModel> surahs) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranBookmarksScreen(surahs: surahs)),
    );

    await _refreshLastPosition();
  }

  Future<void> _openPartitions(List<QuranSurahModel> surahs) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranPartitionScreen(surahs: surahs)),
    );

    await _refreshLastPosition();
  }

  String _normalizeNumbers(String value) {
    const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';
    const persianNumbers = '۰۱۲۳۴۵۶۷۸۹';

    return value.split('').map((character) {
      final arabicIndex = arabicNumbers.indexOf(character);

      if (arabicIndex != -1) {
        return arabicIndex.toString();
      }

      final persianIndex = persianNumbers.indexOf(character);

      if (persianIndex != -1) {
        return persianIndex.toString();
      }

      return character;
    }).join();
  }

  List<QuranSurahModel> _filterSurahs(List<QuranSurahModel> surahs) {
    final query = _normalizeNumbers(searchQuery.trim());

    if (query.isEmpty) return surahs;

    return surahs.where((surah) {
      final nameMatches = surah.name.contains(query);
      final numberMatches = surah.number.toString() == query;

      return nameMatches || numberMatches;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => QuranCubit(QuranLocalData())..loadSurahs(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'القرآن الكريم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text('حدث خطأ أثناء تحميل القرآن\n${state.error}'),
              );
            }

            if (state.surahs.isEmpty) {
              return const Center(child: Text('لا توجد سور لعرضها'));
            }

            _openLastPositionIfAvailable(state.surahs);

            final filteredSurahs = _filterSurahs(state.surahs);

            return Column(
              children: [
                FutureBuilder<Map<String, int>?>(
                  future: _lastPositionFuture,
                  builder: (context, snapshot) {
                    final position = snapshot.data;

                    if (snapshot.connectionState == ConnectionState.waiting ||
                        position == null) {
                      return const SizedBox.shrink();
                    }

                    final surahIndex = state.surahs.indexWhere(
                      (surah) => surah.number == position['surah'],
                    );

                    if (surahIndex == -1) {
                      return const SizedBox.shrink();
                    }

                    final surah = state.surahs[surahIndex];
                    final ayahNumber = position['ayah']!;

                    if (ayahNumber < 1 || ayahNumber > surah.ayahCount) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _openReading(
                              surahs: state.surahs,
                              surahIndex: surahIndex,
                              ayahNumber: ayahNumber,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 30),
                              const SizedBox(height: 8),
                              const Text(
                                'متابعة القراءة',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سورة ${surah.name} - الآية $ayahNumber',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openBookmarks(state.surahs),
                      icon: const Icon(Icons.bookmarks_outlined),
                      label: const Text(
                        'الآيات المحفوظة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openPartitions(state.surahs),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text(
                        'فهرس الأجزاء والأحزاب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة أو رقمها',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close),
                              tooltip: 'مسح البحث',
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      searchQuery.isEmpty
                          ? 'اختر السورة التي تريد قراءتها'
                          : 'نتائج البحث: ${filteredSurahs.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredSurahs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 60,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'لم يتم العثور على سورة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'تأكد من كتابة اسم السورة أو رقمها بشكل صحيح',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _clearSearch,
                                  child: const Text('عرض جميع السور'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          itemCount: filteredSurahs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final surah = filteredSurahs[index];
                            final surahIndex = state.surahs.indexOf(surah);

                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  _openReading(
                                    surahs: state.surahs,
                                    surahIndex: surahIndex,
                                  );
                                },
                                leading: CircleAvatar(
                                  radius: 23,
                                  child: Text(
                                    '${surah.number}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  surah.name,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${surah.ayahCount} آية',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Text(
                                  'اقرأ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
