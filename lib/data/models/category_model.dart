// lib/data/models/category_model.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue; // Color stored as int

  @HiveField(3)
  String iconName; // icon identifier string

  @HiveField(4)
  bool isCustom;

  @HiveField(5)
  bool isExpenseCategory; // true = expense, false = income

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    this.isCustom = false,
    this.isExpenseCategory = true,
  });

  Color get color => Color(colorValue);
}
