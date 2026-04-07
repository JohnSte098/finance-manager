// lib/presentation/providers/category_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/default_categories.dart';
import '../../data/datasources/hive_db.dart';
import '../../data/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<CategoryModel> get all => HiveDb.categories.values.toList();
  List<CategoryModel> get expenseCategories => all.where((c) => c.isExpenseCategory).toList();
  List<CategoryModel> get incomeCategories => all.where((c) => !c.isExpenseCategory).toList();

  /// Seed defaults on first launch
  Future<void> seedDefaults() async {
    if (HiveDb.categories.isEmpty) {
      for (final cat in DefaultCategories.all) {
        await HiveDb.categories.put(cat.id, cat);
      }
      notifyListeners();
    }
  }

  CategoryModel? findById(String id) => HiveDb.categories.get(id);

  /// Add a new custom category
  Future<void> addCustomCategory({
    required String name,
    required Color color,
    required String iconName,
    required bool isExpense,
  }) async {
    final id = _uuid.v4();
    final cat = CategoryModel(
      id: id,
      name: name,
      colorValue: color.value,
      iconName: iconName,
      isCustom: true,
      isExpenseCategory: isExpense,
    );
    await HiveDb.categories.put(id, cat);
    notifyListeners();
  }

  /// Edit an existing custom category
  Future<void> editCustomCategory({
    required String id,
    required String name,
    required Color color,
    required String iconName,
    required bool isExpense,
  }) async {
    final cat = HiveDb.categories.get(id);
    if (cat == null) return;
    cat
      ..name = name
      ..colorValue = color.value
      ..iconName = iconName
      ..isExpenseCategory = isExpense;
    await HiveDb.categories.put(id, cat);
    notifyListeners();
  }

  /// Delete a custom category
  Future<void> deleteCategory(String id) async {
    await HiveDb.categories.delete(id);
    notifyListeners();
  }
}
