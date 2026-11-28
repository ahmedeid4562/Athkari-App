import 'package:athkari_app/features/quran/data/model/quran_surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/quran_partition_local_data.dart';
import '../../data/model/quran_partition_model.dart';
import '../view_model/quran_partition_cubit.dart';
import 'quran_reading_screen.dart';

class QuranPartitionScreen extends StatelessWidget {
  final List<QuranSurahModel> surahs;

  const QuranPartitionScreen({super.key, required this.surahs});

  void _openReading(BuildContext context, QuranPartitionModel partition) {
    final surahIndex = surahs.indexWhere(
      (surah) => surah.number == partition.surahNumber,
    );

    if (surahIndex == -1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReadingScreen(
          surahs: surahs,
          initialIndex: surahIndex,
          initialAyah: partition.ayahNumber,
        ),
      ),
    );
  }

  Widget _buildPartitionList({
    required BuildContext context,
    required List<QuranPartitionModel> partitions,
    required String title,
    required bool isHizb,
  }) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: partitions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final partition = partitions[index];

        final surah = surahs.firstWhere(
          (item) => item.number == partition.surahNumber,
        );

        final displayNumber = isHizb
            ? ((partition.index - 1) ~/ 4) + 1
            : partition.index;

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => _openReading(context, partition),
            leading: CircleAvatar(
              child: Text(
                '$displayNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '$title $displayNumber',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'سورة ${surah.name} - الآية ${partition.ayahNumber}',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
          ),
        );
      },
    );
  }

  Widget _buildPagesList({
    required BuildContext context,
    required List<QuranPartitionModel> pages,
  }) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final page = pages[index];

        final surah = surahs.firstWhere(
          (item) => item.number == page.surahNumber,
        );

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => _openReading(context, page),
            leading: CircleAvatar(
              child: Text(
                '${page.index}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              'الصفحة ${page.index}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'سورة ${surah.name} - الآية ${page.ayahNumber}',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocProvider(
        create: (_) =>
            QuranPartitionCubit(QuranPartitionLocalData())..loadPartitions(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'فهرس المصحف',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.menu_book_rounded), text: 'الأجزاء'),
                Tab(icon: Icon(Icons.bookmarks_outlined), text: 'الأحزاب'),
                Tab(icon: Icon(Icons.auto_stories_rounded), text: 'الصفحات'),
              ],
            ),
          ),
          body: BlocBuilder<QuranPartitionCubit, QuranPartitionState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'حدث خطأ أثناء تحميل الفهرس\n${state.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state.juzs.isEmpty ||
                  state.hizbs.isEmpty ||
                  state.pages.isEmpty) {
                return const Center(child: Text('لا توجد بيانات للفهرس'));
              }

              return TabBarView(
                children: [
                  _buildPartitionList(
                    context: context,
                    partitions: state.juzs,
                    title: 'الجزء',
                    isHizb: false,
                  ),
                  _buildPartitionList(
                    context: context,
                    partitions: state.hizbs,
                    title: 'الحزب',
                    isHizb: true,
                  ),
                  _buildPagesList(context: context, pages: state.pages),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
