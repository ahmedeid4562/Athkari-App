import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/api/daily_dua_local_data.dart';
import '../view_model/daily_dua_cubit.dart';

class DailyDuaScreen extends StatelessWidget {
  const DailyDuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DailyDuaCubit(DailyDuaLocalData())..loadDailyDua(),
      child: const _DailyDuaContent(),
    );
  }
}

class _DailyDuaContent extends StatefulWidget {
  const _DailyDuaContent();

  @override
  State<_DailyDuaContent> createState() => _DailyDuaContentState();
}

class _DailyDuaContentState extends State<_DailyDuaContent> {
  final GlobalKey _imageKey = GlobalKey();

  Future<void> _shareDuaText(DailyDuaState state) async {
    final dua = state.dua;

    if (dua == null) return;

    await SharePlus.instance.share(
      ShareParams(
        text:
            '${dua.title}\n\n${dua.text}\n\n${dua.reference}\n\nمن تطبيق أذكاري',
      ),
    );
  }

  Future<void> _shareDuaImage() async {
    try {
      final boundary =
          _imageKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'image/png', name: 'daily_dua.png'),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر مشاركة صورة الدعاء'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دعاء اليوم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DailyDuaCubit, DailyDuaState>(
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

          final dua = state.dua;

          if (dua == null) {
            return const Center(child: Text('لا يوجد دعاء متاح'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 33,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'دعاء يطمئن قلبك',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'اجعل الدعاء جزءًا من يومك',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _imageKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.lightGold,
                          size: 28,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'أذكاري',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 55,
                          height: 2,
                          color: AppColors.lightGold,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          dua.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          dua.text,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 21,
                            height: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Divider(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dua.reference,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'اللهم اجعل ألسنتنا عامرة بذكرك وقلوبنا مطمئنة بقربك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.lightGold,
                            fontSize: 12,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  '${dua.title}\n\n${dua.text}\n\n${dua.reference}',
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الدعاء'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('نسخ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareDuaText(state),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('مشاركة نص'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _shareDuaImage,
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('مشاركة كصورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<DailyDuaCubit>().changeDua();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('دعاء آخر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'اللهم اجعل ألسنتنا عامرة بذكرك وقلوبنا مطمئنة بقربك',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
