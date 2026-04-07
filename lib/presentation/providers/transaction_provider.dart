// lib/presentation/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/currency_utils.dart';
import '../../data/datasources/hive_db.dart';
import '../../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  /// All transactions sorted newest first
  List<TransactionModel> get all {
    final list = HiveDb.transactions.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<TransactionModel> get expenses => all.where((t) => t.isExpense).toList();
  List<TransactionModel> get income   => all.where((t) => !t.isExpense).toList();

  double get totalIncome  => income.fold(0, (s, t) => s + t.amount);
  double get totalExpense => expenses.fold(0, (s, t) => s + t.amount);
  double get balance      => totalIncome - totalExpense;

  // Monthly stats (current month)
  List<TransactionModel> get thisMonthAll {
    final now = DateTime.now();
    return all.where((t) => t.date.month == now.month && t.date.year == now.year).toList();
  }

  double get monthlyIncome  => thisMonthAll.where((t) => !t.isExpense).fold(0.0, (s, t) => s + t.amount);
  double get monthlyExpense => thisMonthAll.where((t) =>  t.isExpense).fold(0.0, (s, t) => s + t.amount);

  /// Returns expense total grouped by categoryId for this month
  Map<String, double> get monthlyExpenseByCategory {
    final map = <String, double>{};
    for (final t in thisMonthAll.where((t) => t.isExpense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  /// Last 7 days daily expense totals (index 0 = 6 days ago, index 6 = today)
  List<double> get weeklyExpenses {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return all
          .where((t) => t.isExpense &&
              t.date.year  == day.year &&
              t.date.month == day.month &&
              t.date.day   == day.day)
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  /// Search & filter
  List<TransactionModel> search(String query, {String? categoryId, bool? isExpense}) {
    return all.where((t) {
      final matchQuery = query.isEmpty ||
          t.title.toLowerCase().contains(query.toLowerCase()) ||
          (t.note?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchCat = categoryId == null || t.categoryId == categoryId;
      final matchType = isExpense == null || t.isExpense == isExpense;
      return matchQuery && matchCat && matchType;
    }).toList();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    required bool isExpense,
    String? note,
    String currency = 'USD',
    bool isRecurring = false,
  }) async {
    final id = _uuid.v4();
    final tx = TransactionModel(
      id: id,
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      isExpense: isExpense,
      note: note,
      currency: currency,
      isRecurring: isRecurring,
      recurringId: isRecurring ? _uuid.v4() : null,
    );
    await HiveDb.transactions.put(id, tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveDb.transactions.delete(id);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await HiveDb.transactions.put(tx.id, tx);
    notifyListeners();
  }

  /// Export all transactions as list of maps for Excel/CSV
  List<Map<String, dynamic>> exportData(String currency) {
    return all.map((t) => {
      'Date': '${t.date.day}/${t.date.month}/${t.date.year}',
      'Type': t.isExpense ? 'Expense' : 'Income',
      'Category': t.categoryId,
      'Description': t.title,
      'Note': t.note ?? '',
      'Amount': CurrencyUtils.convert(t.amount, t.currency, currency).toStringAsFixed(2),
      'Currency': currency,
    }).toList();
  }
}
