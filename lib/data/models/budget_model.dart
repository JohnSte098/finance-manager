// lib/data/models/budget_model.dart
import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double limitAmount;

  @HiveField(3)
  int month; // 1-12

  @HiveField(4)
  int year;

  @HiveField(5)
  bool notified80Percent;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    this.notified80Percent = false,
  });
}
