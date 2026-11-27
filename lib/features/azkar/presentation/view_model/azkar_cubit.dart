import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/azkar_category_model.dart';

class AzkarCubit extends Cubit<List<AzkarCategoryModel>> {
  AzkarCubit() : super(_categories);

  static const List<AzkarCategoryModel> _categories = [
    AzkarCategoryModel(
      id: 'morning',
      title: 'أذكار الصباح',
      description: 'ابدأ يومك بذكر الله',
      count: 'أذكار يومية',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFC49A45),
    ),
    AzkarCategoryModel(
      id: 'evening',
      title: 'أذكار المساء',
      description: 'اختم يومك بذكر الله',
      count: 'أذكار يومية',
      icon: Icons.nightlight_round,
      color: Color(0xFF6486B5),
    ),
    AzkarCategoryModel(
      id: 'after_prayer',
      title: 'أذكار بعد الصلاة',
      description: 'أذكار تحافظ عليها بعد صلاتك',
      count: 'أذكار الصلاة',
      icon: Icons.mosque_rounded,
      color: Color(0xFF176B55),
    ),
    AzkarCategoryModel(
      id: 'sleep',
      title: 'أذكار النوم',
      description: 'اختم يومك بذكر الله',
      count: 'أذكار النوم',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF8874B8),
    ),
    AzkarCategoryModel(
      id: 'waking',
      title: 'أذكار الاستيقاظ',
      description: 'ابدأ يومك بالحمد والشكر',
      count: 'أذكار الاستيقاظ',
      icon: Icons.alarm_rounded,
      color: Color(0xFF6A9B83),
    ),
    AzkarCategoryModel(
      id: 'general',
      title: 'أذكار متنوعة',
      description: 'أذكار منوعة لكل وقت',
      count: 'أذكار مختلفة',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFBB6C78),
    ),
  ];
}