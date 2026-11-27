import 'package:flutter/material.dart';

class AzkarCategoryModel {
  final String id;
  final String title;
  final String description;
  final String count;
  final IconData icon;
  final Color color;

  const AzkarCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.count,
    required this.icon,
    required this.color,
  });
}