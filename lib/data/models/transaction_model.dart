// lib/data/models/transaction_model.dart
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool isExpense; // false = income

  @HiveField(6)
  String? note;

  @HiveField(7)
  String currency; // 'USD', 'EUR', 'INR'

  @HiveField(8)
  bool isRecurring;

  @HiveField(9)
  String? recurringId; // group recurrences

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.isExpense,
    this.note,
    this.currency = 'USD',
    this.isRecurring = false,
    this.recurringId,
  });
}
