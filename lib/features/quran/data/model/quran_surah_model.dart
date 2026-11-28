import 'quran_ayah_model.dart';

class QuranSurahModel {
  final int number;
  final String name;
  final List<QuranAyahModel> ayahs;

  const QuranSurahModel({
    required this.number,
    required this.name,
    required this.ayahs,
  });

  int get ayahCount => ayahs.length;
}
