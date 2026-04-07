// lib/data/datasources/hive_db.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';

class HiveDb {
  static const String txBox       = 'transactions';
  static const String catBox      = 'categories';
  static const String budgetBox   = 'budgets';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());

    await Hive.openBox<TransactionModel>(txBox);
    await Hive.openBox<CategoryModel>(catBox);
    await Hive.openBox<BudgetModel>(budgetBox);
    await Hive.openBox(settingsBox);
  }

  static Box<TransactionModel> get transactions => Hive.box<TransactionModel>(txBox);
  static Box<CategoryModel>    get categories   => Hive.box<CategoryModel>(catBox);
  static Box<BudgetModel>      get budgets       => Hive.box<BudgetModel>(budgetBox);
  static Box                   get settings      => Hive.box(settingsBox);
}
