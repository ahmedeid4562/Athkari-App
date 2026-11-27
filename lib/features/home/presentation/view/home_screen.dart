import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/daily_progress_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../azkar/presentation/view/azkar_screen.dart';
import '../../../daily_dua/presentation/view/daily_dua_screen.dart';
import '../../../favorites/presentation/view/favorites_screen.dart';
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
                    const SizedBox(height: 28),
                    _buildDailyVerse(context),
                    const SizedBox(height: 25),
                    _buildProgressCard(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      context,
                      'أقسام التطبيق',
                      'اختر القسم الذي تريد البدء به',
                    ),
                    const SizedBox(height: 18),
                    _buildCategories(context),
                    const SizedBox(height: 28),
                    _buildDailyReminder(context),
                    const SizedBox(height: 25),
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
                      fontSize: 15,
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
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.mosque_rounded,
            color: theme.colorScheme.primary,
            size: 30,
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
        borderRadius: BorderRadius.circular(26),
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
                size: 30,
              ),
              const SizedBox(height: 18),
              const Text(
                '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'سورة البقرة - الآية 152',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(23),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: theme.colorScheme.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إنجازات اليوم',
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
          const SizedBox(height: 22),
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
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
      _CategoryItem(
        title: 'أذكار الصباح والمساء',
        subtitle: 'حصّن يومك بذكر الله',
        icon: Icons.wb_twilight_rounded,
        backgroundIcon: Icons.wb_sunny_rounded,
        color: const Color(0xFF176B55),
        lightColor: const Color(0xFFE1F1E9),
      ),
      _CategoryItem(
        title: 'السبحة الإلكترونية',
        subtitle: 'سبّح واستغفر',
        icon: Icons.radio_button_checked_rounded,
        backgroundIcon: Icons.circle_outlined,
        color: const Color(0xFFC49A45),
        lightColor: const Color(0xFFF8F0DC),
      ),
      _CategoryItem(
        title: 'دعاء اليوم',
        subtitle: 'دعاء يرافق يومك',
        icon: Icons.volunteer_activism_rounded,
        backgroundIcon: Icons.auto_awesome_rounded,
        color: const Color(0xFF6486B5),
        lightColor: const Color(0xFFE6EDF7),
      ),
      _CategoryItem(
        title: 'الأذكار المفضلة',
        subtitle: 'أذكارك المحفوظة',
        icon: Icons.favorite_rounded,
        backgroundIcon: Icons.favorite_rounded,
        color: const Color(0xFFBB6C78),
        lightColor: const Color(0xFFF8E8EB),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        return _buildCategoryCard(context, categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryItem item) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(23),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openCategory(context, item.title),
        child: Stack(
          children: [
            Positioned(
              top: -25,
              left: -25,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              top: 35,
              left: 20,
              child: Icon(
                item.backgroundIcon,
                size: 75,
                color: item.color.withValues(alpha: 0.07),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 57,
                    height: 57,
                    decoration: BoxDecoration(
                      color: item.lightColor,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Icon(item.icon, color: item.color, size: 31),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    maxLines: 2,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 15,
                          color: item.color,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 28,
                        height: 3,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
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
    }

    if (screen == null) return;

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));

    await _loadDailyProgress();
  }

  Widget _buildDailyReminder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
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
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 15),
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
        ],
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
  final IconData icon;
  final IconData backgroundIcon;
  final Color color;
  final Color lightColor;

  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundIcon,
    required this.color,
    required this.lightColor,
  });
}
