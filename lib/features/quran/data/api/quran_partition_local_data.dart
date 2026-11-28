import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../model/quran_partition_model.dart';

class QuranPartitionLocalData {
  Future<List<QuranPartitionModel>> loadJuzs() async {
    final xmlString = await rootBundle.loadString(
      'assets/data/quran/quran-data.xml',
    );

    final document = XmlDocument.parse(xmlString);

    return document.findAllElements('juz').map((element) {
      return QuranPartitionModel.fromXml({
        for (final attribute in element.attributes)
          attribute.name.local: attribute.value,
      });
    }).toList();
  }

  Future<List<QuranPartitionModel>> loadQuarters() async {
    final xmlString = await rootBundle.loadString(
      'assets/data/quran/quran-data.xml',
    );

    final document = XmlDocument.parse(xmlString);

    return document.findAllElements('quarter').map((element) {
      return QuranPartitionModel.fromXml({
        for (final attribute in element.attributes)
          attribute.name.local: attribute.value,
      });
    }).toList();
  }

  Future<List<QuranPartitionModel>> loadPages() async {
    final xmlString = await rootBundle.loadString(
      'assets/data/quran/quran-data.xml',
    );

    final document = XmlDocument.parse(xmlString);

    return document.findAllElements('page').map((element) {
      return QuranPartitionModel.fromXml({
        for (final attribute in element.attributes)
          attribute.name.local: attribute.value,
      });
    }).toList();
  }
}
