import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('حول أذكاري'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.82),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/app_icon/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFF176B55),
                          child: Icon(
                            Icons.mosque_rounded,
                            size: 55,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'أذكاري',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رفيقك اليومي لذكر الله',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'اجعل لسانك عامرًا بذكر الله',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildSection(
            context,
            title: 'عن أذكاري',
            icon: Icons.info_outline_rounded,
            description: 'تطبيق أذكاري يساعدك على المحافظة على ذكر الله من خلال الأذكار اليومية، والمسبحة الإلكترونية، والقرآن الكريم، والأدعية والمفضلة والتذكيرات.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'مميزات التطبيق',
            icon: Icons.stars_rounded,
            child: Column(
              children: [
                _buildFeature(
                  context,
                  Icons.menu_book_rounded,
                  'القرآن الكريم',
                ),
                _buildFeature(
                  context,
                  Icons.auto_awesome_rounded,
                  'أذكار الصباح والمساء',
                ),
                _buildFeature(
                  context,
                  Icons.radio_button_checked_rounded,
                  'المسبحة الإلكترونية',
                ),
                _buildFeature(
                  context,
                  Icons.favorite_rounded,
                  'الأذكار والأدعية المفضلة',
                ),
                _buildFeature(
                  context,
                  Icons.notifications_active_rounded,
                  'تذكيرات الأذكار',
                ),
                _buildFeature(
                  context,
                  Icons.dark_mode_rounded,
                  'الوضع الفاتح والداكن',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'مصدر القرآن الكريم',
            icon: Icons.menu_book_rounded,
            description: 'تم استخدام نص القرآن الكريم بالرسم العثماني من مشروع Tanzil Project، وفقًا لرخصة Creative Commons Attribution 3.0 (CC BY 3.0).',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SelectableText(
                  'Tanzil Project\nhttps://tanzil.net',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Quran Text Copyright (C) 2007-2026 Tanzil Project',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'الإصدار',
            icon: Icons.verified_outlined,
            description: 'الإصدار 1.0.0',
          ),
          const SizedBox(height: 28),
          Icon(
            Icons.favorite_rounded,
            color: isDark ? AppColors.darkGold : AppColors.lightGold,
            size: 25,
          ),
          const SizedBox(height: 10),
          Text(
            'صُنع بكل حب لخدمة ذكر الله',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? description,
    Widget? child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description case final value?) ...[
              const SizedBox(height: 15),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.9),
              ),
            ],
            ?child,
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Icon(icon, size: 21, color: theme.colorScheme.primary),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
