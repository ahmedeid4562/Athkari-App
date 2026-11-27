// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أذكاري';

  @override
  String get welcome => 'أهلاً بك في أذكاري';

  @override
  String get home => 'الرئيسية';

  @override
  String get azkar => 'الأذكار';

  @override
  String get tasbeeh => 'التسبيح';

  @override
  String get favorites => 'المفضلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get dailyDua => 'دعاء اليوم';
}
