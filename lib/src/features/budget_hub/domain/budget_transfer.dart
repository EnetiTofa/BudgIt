// lib/src/features/budget_hub/domain/budget_transfer.dart

import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'budget_transfer.g.dart';

// KEEP typeId: 9 (or whatever your WalletAdjustment was) to prevent data loss!
@HiveType(typeId: 9)
class BudgetTransfer extends Equatable with HiveObjectMixin {
  BudgetTransfer({
    required this.id,
    required this.fromCategoryId,
    required this.toCategoryId,
    required this.amount,
    required this.date,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromCategoryId;

  @HiveField(2)
  final String toCategoryId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  @override
  List<Object?> get props => [id, fromCategoryId, toCategoryId, amount, date];

  BudgetTransfer copyWith({
    String? id,
    String? fromCategoryId,
    String? toCategoryId,
    double? amount,
    DateTime? date,
  }) {
    return BudgetTransfer(
      id: id ?? this.id,
      fromCategoryId: fromCategoryId ?? this.fromCategoryId,
      toCategoryId: toCategoryId ?? this.toCategoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
