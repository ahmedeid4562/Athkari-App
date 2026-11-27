import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/azkar_model.dart';

class AzkarLocalData {
  Future<List<AzkarModel>> getAzkar(String categoryId) async {
    final response = await rootBundle.loadString(
      'assets/data/azkar/azkar.json',
    );

    final Map<String, dynamic> data = jsonDecode(response);

    final List<dynamic> azkarList = data[categoryId] ?? [];

    return azkarList
        .map((item) => AzkarModel.fromJson(item))
        .toList();
  }
}