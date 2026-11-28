import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/daily_progress_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../azkar/presentation/view/azkar_screen.dart';
import '../../../daily_dua/presentation/view/daily_dua_screen.dart';
import '../../../favorites/presentation/view/favorites_screen.dart';
import '../../../quran/presentation/view/quran_surah_screen.dart';
import '../../../reminders/presentation/view/reminders_screen.dart';
import '../../../settings/presentation/view/settings_screen.dart';
import '../../../tasbeeh/presentation/view/tasbeeh_screen.dart';
import '../view_model/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;

  const HomeScreen({super.key, required this.themeController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DailyProgressService _progressService = DailyProgressService();

  int _completedToday = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyProgress();
  }

  Future<void> _loadDailyProgress() async {
    final count = await _progressService.getCompletedCount();

    if (!mounted) return;

    setState(() {
      _completedToday = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context),
                    const SizedBox(height: 25),
                    _buildDailyVerse(context),
                    const SizedBox(height: 20),
                    _buildProgressCard(context),
                    const SizedBox(height: 28),
                    _buildSectionTitle(
                      context,
                      'أقسام التطبيق',
                      'اختر القسم الذي تريد البدء به',
                    ),
                    const SizedBox(height: 17),
                    _buildCategories(context),
                    const SizedBox(height: 25),
                    _buildDailyReminder(context),
                    const SizedBox(height: 22),
                    _buildFooter(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<HomeCubit, String>(
                builder: (context, greeting) {
                  return Text(
                    greeting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 7),
              Text(
                'أهلاً بك في أذكاري',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              const SizedBox(height: 5),
              Text('ابدأ يومك بذكر الله', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(themeController: widget.themeController),
              ),
            );
          },
          icon: const Icon(Icons.settings_rounded),
          iconSize: 25,
          tooltip: 'الإعدادات',
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            Icons.mosque_rounded,
            color: theme.colorScheme.primary,
            size: 29,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyVerse(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF247A60), Color(0xFF176B55), Color(0xFF0D493B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -25, left: -20, child: _decorationCircle(110)),
          Positioned(bottom: -45, right: -20, child: _decorationCircle(130)),
          Column(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.lightGold,
                size: 29,
              ),
              const SizedBox(height: 16),
              const Text(
                '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'سورة البقرة - الآية 152',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 15),
              const Text(
                'اجعل لسانك رطبًا بذكر الله',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorationCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    const totalAzkar = 77;

    final progress = (_completedToday / totalAzkar).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.lightGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.lightGold,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إنجازك اليومي',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'واصل ذكرك واجعل يومك عامرًا بالطاعة',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الأذكار المكتملة', style: theme.textTheme.bodyMedium),
              Text(
                '$_completedToday / $totalAzkar',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${(progress * 100).round()}% من إنجازك اليوم',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      const _CategoryItem(
        title: 'القرآن الكريم',
        subtitle: 'اقرأ آيات الله وتدبرها',
        imagePath: 'assets/images/home/quran.jpg',
        color: Color(0xFF176B55),
        icon: Icons.menu_book_rounded,
      ),
      const _CategoryItem(
        title: 'أذكار الصباح والمساء',
        subtitle: 'حصّن يومك بذكر الله',
        imagePath: 'assets/images/home/azkar.jpg',
        color: Color(0xFF176B55),
        icon: Icons.wb_twilight_rounded,
      ),
      const _CategoryItem(
        title: 'السبحة الإلكترونية',
        subtitle: 'سبّح واستغفر',
        imagePath: 'assets/images/home/tasbeeh.jpg',
        color: Color(0xFFC49A45),
        icon: Icons.circle_outlined,
      ),
      const _CategoryItem(
        title: 'دعاء اليوم',
        subtitle: 'دعاء يرافق يومك',
        imagePath: 'assets/images/home/dua.jpg',
        color: Color(0xFF6486B5),
        icon: Icons.volunteer_activism_rounded,
      ),
      const _CategoryItem(
        title: 'الأذكار المفضلة',
        subtitle: 'أذكارك المحفوظة',
        imagePath: 'assets/images/home/favorites.jpg',
        color: Color(0xFFBB6C78),
        icon: Icons.favorite_rounded,
      ),
      const _CategoryItem(
        title: 'التذكيرات',
        subtitle: 'نظّم مواعيد أذكارك',
        imagePath: 'assets/images/home/reminders.jpg',
        color: Color(0xFF176B55),
        icon: Icons.notifications_active_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final double cardWidth;
        final double cardHeight;

        if (screenWidth >= 1200) {
          cardWidth = 350;
          cardHeight = 220;
        } else if (screenWidth >= 800) {
          cardWidth = (screenWidth - 28) / 3;
          cardHeight = 205;
        } else {
          cardWidth = (screenWidth - 13) / 2;
          cardHeight = 165;
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 13,
          runSpacing: 13,
          children: categories.map((item) {
            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildCategoryCard(context, item),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryItem item) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openCategory(context, item.title),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [item.color.withValues(alpha: 0.8), item.color],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 55,
                    ),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 21),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 11,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 27,
                    height: 27,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategory(BuildContext context, String title) async {
    Widget? screen;

    switch (title) {
      case 'القرآن الكريم':
        screen = const QuranSurahScreen();
        break;
      case 'أذكار الصباح والمساء':
        screen = const AzkarScreen();
        break;
      case 'السبحة الإلكترونية':
        screen = const TasbeehScreen();
        break;
      case 'الأذكار المفضلة':
        screen = const FavoritesScreen();
        break;
      case 'دعاء اليوم':
        screen = const DailyDuaScreen();
        break;
      case 'التذكيرات':
        screen = const RemindersScreen();
        break;
    }

    if (screen == null) return;

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));

    await _loadDailyProgress();
  }

  Widget _buildDailyReminder(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RemindersScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 27,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لا تنسَ ذكر الله',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'اجعل الذكر عادة يومية لا تنقطع.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        'أذكاري • رفيقك اليومي لذكر الله',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;
  final IconData icon;

  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
    required this.icon,
  });
}
