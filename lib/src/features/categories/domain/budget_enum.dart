// lib/src/features/categories/domain/budget.dart

import 'package:hive/hive.dart';

part 'budget_enum.g.dart';

// This enum is now only used for the UI to help with budget entry.
@HiveType(typeId: 1)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  yearly,
}