import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../favorites/data/api/favorites_local_data.dart';
import '../../../favorites/presentation/view_model/favorites_cubit.dart';
import '../../data/api/azkar_local_data.dart';
import '../../data/model/azkar_category_model.dart';
import '../../data/model/azkar_model.dart';
import '../view_model/azkar_details_cubit.dart';

class AzkarDetailsScreen extends StatelessWidget {
  final AzkarCategoryModel category;

  const AzkarDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AzkarDetailsCubit(AzkarLocalData())..loadAzkar(category.id),
        ),
        BlocProvider(
          create: (_) => FavoritesCubit(FavoritesLocalData())..loadFavorites(),
        ),
      ],
      child: _AzkarDetailsContent(category: category),
    );
  }
}

class _AzkarDetailsContent extends StatelessWidget {
  final AzkarCategoryModel category;

  const _AzkarDetailsContent({required this.category});

  void _copyZekr(BuildContext context, AzkarModel azkar) {
    Clipboard.setData(
      ClipboardData(
        text: '${azkar.text}\n\nعدد التكرار: ${azkar.repeat}\n\nالمصدر: ${azkar.reference}',
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

  Future<void> _shareZekr(BuildContext context, AzkarModel azkar) async {
    final text = '''
${azkar.text}

عدد التكرار: ${azkar.repeat}

المصدر: ${azkar.reference}

من تطبيق أذكاري
''';

    await SharePlus.instance.share(
      ShareParams(text: text, title: 'ذكر من تطبيق أذكاري'),
    );
  }

  Future<void> _shareZekrAsImage(BuildContext context, AzkarModel azkar) async {
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
              child: _ShareZekrImage(azkar: azkar),
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
        title: Text(
          category.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AzkarDetailsCubit>().resetCounter();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'إعادة التكرار',
          ),
        ],
      ),
      body: BlocBuilder<AzkarDetailsCubit, AzkarDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.azkar.isEmpty) {
            return const Center(
              child: Text('لا توجد أذكار في هذا القسم حاليًا'),
            );
          }

          if (state.isCompleted) {
            return _buildCompleted(context);
          }

          final azkar = state.currentAzkar!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              children: [
                _buildProgress(context, state),
                const SizedBox(height: 22),
                _buildZekrCard(context, azkar),
                const SizedBox(height: 22),
                Text(
                  'عدد التكرارات المتبقية',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                GestureDetector(
                  onTap: () {
                    context.read<AzkarDetailsCubit>().decrement();
                  },
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.75),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${state.remaining}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'اضغط على الدائرة للتسبيح',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: theme.colorScheme.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'استمر في الذكر، وسيتم الانتقال تلقائيًا',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgress(BuildContext context, AzkarDetailsState state) {
    final theme = Theme.of(context);

    final progress = state.azkar.isEmpty
        ? 0.0
        : state.completedCount / state.azkar.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدمك في الأذكار',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${state.completedCount}/${state.azkar.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.10,
              ),
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZekrCard(BuildContext context, AzkarModel azkar) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Icon(
              Icons.mosque_rounded,
              size: 65,
              color: theme.colorScheme.primary.withValues(alpha: 0.035),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.lightGold,
                    size: 22,
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _copyZekr(context, azkar),
                        tooltip: 'نسخ الذكر',
                        icon: Icon(
                          Icons.copy_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _shareZekr(context, azkar),
                        tooltip: 'مشاركة الذكر',
                        icon: Icon(
                          Icons.share_rounded,
                          color: theme.colorScheme.primary,
                          size: 21,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _shareZekrAsImage(context, azkar),
                        tooltip: 'مشاركة الذكر كصورة',
                        icon: Icon(
                          Icons.image_rounded,
                          color: theme.colorScheme.primary,
                          size: 21,
                        ),
                      ),
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          final isFavorite = context
                              .read<FavoritesCubit>()
                              .isFavorite(azkar);

                          return IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: state.isLoading
                                ? null
                                : () async {
                                    await context
                                        .read<FavoritesCubit>()
                                        .toggleFavorite(azkar);

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isFavorite
                                              ? 'تم حذف الذكر من المفضلة'
                                              : 'تمت إضافة الذكر إلى المفضلة',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : theme.colorScheme.onSurface,
                              size: 22,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                azkar.text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  height: 1.9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  azkar.reference,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'عدد التكرار: ${azkar.repeat}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'تقبل الله منك',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'أحسنت! لقد أتممت جميع أذكار هذا القسم.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('العودة للأذكار'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareZekrImage extends StatelessWidget {
  final AzkarModel azkar;

  const _ShareZekrImage({required this.azkar});

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
