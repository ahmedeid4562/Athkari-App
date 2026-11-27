import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/api/favorites_local_data.dart';
import '../view_model/favorites_cubit.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit(FavoritesLocalData())..loadFavorites(),
      child: const _FavoritesContent(),
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  const _FavoritesContent();

  void _copyZekr(BuildContext context, dynamic azkar) {
    Clipboard.setData(
      ClipboardData(
        text:
            '${azkar.text}\n\nعدد التكرار: ${azkar.repeat}\n\nالمصدر: ${azkar.reference}',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الذكر'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareZekr(BuildContext context, dynamic azkar) async {
    final text =
        '''
${azkar.text}

عدد التكرار: ${azkar.repeat}

المصدر: ${azkar.reference}

من تطبيق أذكاري
''';

    await SharePlus.instance.share(
      ShareParams(text: text, title: 'ذكر من تطبيق أذكاري'),
    );
  }

  Future<void> _shareZekrAsImage(BuildContext context, dynamic azkar) async {
    final boundaryKey = GlobalKey();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await Future.delayed(const Duration(milliseconds: 300));

              final renderObject = boundaryKey.currentContext
                  ?.findRenderObject();

              if (renderObject is! RenderRepaintBoundary) {
                throw Exception('تعذر إنشاء صورة الذكر');
              }

              final ui.Image image = await renderObject.toImage(pixelRatio: 3);

              final byteData = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );

              image.dispose();

              if (byteData == null) {
                throw Exception('تعذر تحويل الصورة');
              }

              final bytes = byteData.buffer.asUint8List();

              if (!dialogContext.mounted) return;

              Navigator.of(dialogContext).pop();

              if (!context.mounted) return;

              await SharePlus.instance.share(
                ShareParams(
                  title: 'ذكر من تطبيق أذكاري',
                  text: 'ذكر من تطبيق أذكاري',
                  files: [
                    XFile.fromData(
                      bytes,
                      mimeType: 'image/png',
                      name: 'athkari.png',
                    ),
                  ],
                ),
              );
            } catch (e) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء تجهيز الصورة: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          });

          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: RepaintBoundary(
              key: boundaryKey,
              child: _FavoriteZekrImage(azkar: azkar),
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذرت مشاركة الصورة: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأذكار المفضلة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (state.favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: theme.colorScheme.primary,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'لديك ${state.favorites.length} أذكار محفوظة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  itemCount: state.favorites.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final azkar = state.favorites[index];

                    return _buildFavoriteCard(context, azkar: azkar);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 55,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'لا توجد أذكار مفضلة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'احتفظ بالأذكار التي تحبها بالضغط على علامة القلب لتجدها هنا بسهولة.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, {required dynamic azkar}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.secondary,
                size: 21,
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                padding: EdgeInsets.zero,
                onPressed: () => _copyZekr(context, azkar),
                icon: Icon(
                  Icons.copy_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'نسخ الذكر',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                padding: EdgeInsets.zero,
                onPressed: () => _shareZekr(context, azkar),
                icon: Icon(
                  Icons.share_rounded,
                  color: theme.colorScheme.primary,
                  size: 21,
                ),
                tooltip: 'مشاركة الذكر',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                padding: EdgeInsets.zero,
                onPressed: () => _shareZekrAsImage(context, azkar),
                icon: Icon(
                  Icons.image_rounded,
                  color: theme.colorScheme.primary,
                  size: 21,
                ),
                tooltip: 'مشاركة الذكر كصورة',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _showRemoveDialog(context, azkar);
                },
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                tooltip: 'حذف من المفضلة',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            azkar.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 19,
              height: 1.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              azkar.reference,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'عدد التكرار: ${azkar.repeat}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, dynamic azkar) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
          title: const Text('حذف من المفضلة'),
          content: const Text(
            'هل تريد حذف هذا الذكر من قائمة المفضلة؟',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<FavoritesCubit>().removeFavorite(azkar);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteZekrImage extends StatelessWidget {
  final dynamic azkar;

  const _FavoriteZekrImage({required this.azkar});

  @override
  Widget build(BuildContext context) {
    final fontSize = azkar.text.length > 250
        ? 17.0
        : azkar.text.length > 150
        ? 19.0
        : 23.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF124D3E), Color(0xFF176B55), Color(0xFF23866A)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD6B76C), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mosque_rounded,
              color: Color(0xFFD6B76C),
              size: 38,
            ),
            const SizedBox(height: 8),
            const Text(
              'أذكاري',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Container(width: 65, height: 2, color: const Color(0xFFD6B76C)),
            const SizedBox(height: 18),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFD6B76C),
              size: 22,
            ),
            const SizedBox(height: 14),
            Text(
              azkar.text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                height: 1.7,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD6B76C).withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                'عدد التكرار: ${azkar.repeat}',
                style: const TextStyle(
                  color: Color(0xFFFFE5A3),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              azkar.reference,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(height: 1, width: double.infinity, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'شارك الأجر ولا تنسَ ذكر الله',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFE5A3),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
