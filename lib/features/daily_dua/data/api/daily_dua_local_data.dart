import 'package:athkari_app/features/daily_dua/data/model/daily_dua_model.dart';

class DailyDuaLocalData {
  final List<DailyDuaModel> _duas = const [
    DailyDuaModel(
      id: 1,
      title: 'دعاء الاستغفار',
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ',
      reference: 'من دعاء سيد الاستغفار - صحيح البخاري',
    ),
    DailyDuaModel(
      id: 2,
      title: 'دعاء طلب الرحمة',
      text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      reference: 'سورة البقرة، الآية 201',
    ),
    DailyDuaModel(
      id: 3,
      title: 'دعاء طلب العلم',
      text: 'رَبِّ زِدْنِي عِلْمًا',
      reference: 'سورة طه، الآية 114',
    ),
    DailyDuaModel(
      id: 4,
      title: 'دعاء التيسير',
      text: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      reference: 'سورة طه، الآيتان 25-26',
    ),
    DailyDuaModel(
      id: 5,
      title: 'دعاء الثبات',
      text: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      reference: 'سنن الترمذي',
    ),
  ];

  List<DailyDuaModel> getDuas() => _duas;

  DailyDuaModel getDailyDua() {
    final day = DateTime.now().difference(
      DateTime(DateTime.now().year, 1, 1),
    ).inDays;

    return _duas[day % _duas.length];
  }
}