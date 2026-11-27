import 'package:flutter/material.dart';

import '../../../../core/theme/theme_controller.dart';
import '../../../reminders/presentation/view/reminders_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController;

  const SettingsScreen({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: themeController,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'المظهر',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر المظهر المناسب لك',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _buildThemeOption(
                context,
                title: 'الوضع التلقائي',
                subtitle: 'حسب إعدادات الجهاز',
                icon: Icons.brightness_auto_rounded,
                mode: ThemeMode.system,
              ),
              _buildThemeOption(
                context,
                title: 'الوضع الفاتح',
                subtitle: 'استخدام المظهر الفاتح',
                icon: Icons.light_mode_rounded,
                mode: ThemeMode.light,
              ),
              _buildThemeOption(
                context,
                title: 'الوضع الداكن',
                subtitle: 'استخدام المظهر الداكن',
                icon: Icons.dark_mode_rounded,
                mode: ThemeMode.dark,
              ),
              const SizedBox(height: 30),
              Text(
                'التذكيرات',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  title: const Text(
                    'تذكيرات الأذكار',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'تحديد مواعيد أذكار الصباح والمساء',
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RemindersScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      color: theme.colorScheme.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أذكاري',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رفيقك اليومي لذكر الله',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final theme = Theme.of(context);
    final isSelected = themeController.themeMode == mode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => themeController.changeTheme(mode),
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 27,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          isSelected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}