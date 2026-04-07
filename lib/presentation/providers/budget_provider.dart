// lib/presentation/providers/budget_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/hive_db.dart';
import '../../data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<BudgetModel> get all => HiveDb.budgets.values.toList();

  BudgetModel? getBudget(String categoryId, {int? month, int? year}) {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;
    try {
      return all.firstWhere(
        (b) => b.categoryId == categoryId && b.month == m && b.year == y,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setBudget({
    required String categoryId,
    required double limit,
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;

    final existing = getBudget(categoryId, month: m, year: y);
    if (existing != null) {
      existing.limitAmount = limit;
      existing.notified80Percent = false;
      await HiveDb.budgets.put(existing.id, existing);
    } else {
      final id = _uuid.v4();
      final budget = BudgetModel(
        id: id,
        categoryId: categoryId,
        limitAmount: limit,
        month: m,
        year: y,
      );
      await HiveDb.budgets.put(id, budget);
    }
    notifyListeners();
  }

  Future<void> removeBudget(String categoryId) async {
    final now = DateTime.now();
    final existing = getBudget(categoryId, month: now.month, year: now.year);
    if (existing != null) {
      await HiveDb.budgets.delete(existing.id);
      notifyListeners();
    }
  }

  /// Returns percent spent (0.0-1.0+) for a category this month
  double getSpentPercent(String categoryId, double spent) {
    final budget = getBudget(categoryId);
    if (budget == null || budget.limitAmount == 0) return 0;
    return spent / budget.limitAmount;
  }

  /// Check if budget is at 80% - returns category IDs that triggered
  List<String> checkWarnings(Map<String, double> spentByCategory) {
    final warnings = <String>[];
    for (final entry in spentByCategory.entries) {
      final budget = getBudget(entry.key);
      if (budget == null) continue;
      final pct = entry.value / budget.limitAmount;
      if (pct >= 0.8 && !budget.notified80Percent) {
        budget.notified80Percent = true;
        HiveDb.budgets.put(budget.id, budget);
        warnings.add(entry.key);
      }
    }
    return warnings;
  }
}
