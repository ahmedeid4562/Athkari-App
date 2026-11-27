import 'package:flutter/material.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'features/splash/presentation/view/splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await NotificationService.initialize();
await NotificationService.requestPermission();
  final themeController = ThemeController();

  await themeController.loadTheme();

  runApp(
    AthkariApp(
      themeController: themeController,
    ),
  );
}

class AthkariApp extends StatelessWidget {
  final ThemeController themeController;

  const AthkariApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'أذكاري',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates:
              AppLocalizations.localizationsDelegates,
        home: SplashScreen(
  themeController: themeController,
),
        );
      },
    );
  }
}