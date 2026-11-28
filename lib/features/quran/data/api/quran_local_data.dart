import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../model/quran_ayah_model.dart';
import '../model/quran_surah_model.dart';

class QuranLocalData {
  Future<List<QuranSurahModel>> loadSurahs() async {
    final xmlString = await rootBundle.loadString(
      'assets/data/quran/quran-uthmani.xml',
    );

    final document = XmlDocument.parse(xmlString);

    final surahElements = document.findAllElements('sura');

    final surahs = surahElements.map((surahElement) {
      final number = int.parse(surahElement.getAttribute('index')!);
      final name = surahElement.getAttribute('name')!;

      final ayahs = surahElement.findElements('aya').map((ayahElement) {
        return QuranAyahModel(
          number: int.parse(ayahElement.getAttribute('index')!),
          text: ayahElement.getAttribute('text')!,
        );
      }).toList();

      return QuranSurahModel(number: number, name: name, ayahs: ayahs);
    }).toList();

    return surahs;
  }
}
