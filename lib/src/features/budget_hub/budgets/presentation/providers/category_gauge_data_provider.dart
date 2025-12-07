// lib/src/features/budget_hub/budgets/presentation/providers/category_gauge_data_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/unified_budget_gauge.dart'; 
import 'package:budgit/src/utils/palette_generator.dart';

part 'category_gauge_data_provider.g.dart';

class CategoryGaugeData {
  const CategoryGaugeData({
    required this.segments,
    required this.totalBudget,
    required this.totalSpent,
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double totalSpent;
}

// CHANGED: Removed 'Future' wrapper and 'async' keyword.
// This is now a synchronous provider that recalculates instantly.
@riverpod
CategoryGaugeData categoryGaugeData(
  CategoryGaugeDataRef ref, {
  required Category category,
  required DateTime month,
}) {
  // We grab the value synchronously. 
  // We assume the parent screen has already ensured this data is loaded.
  final allOccurrences =
      ref.watch(allTransactionOccurrencesProvider).value ?? [];

  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);

  final monthlyPayments = allOccurrences
      .whereType<OneOffPayment>()
      .where((p) =>
          p.category.id == category.id &&
          !p.date.isBefore(timeFrameStartDate) &&
          !p.date.isAfter(timeFrameEndDate))
      .toList();

  final timeFrameDays = timeFrameEndDate.day;
  final double dailyRate = (category.budgetAmount * 12) / 365.25;
  final projectedBudget = dailyRate * timeFrameDays;

  final recurringSpending = monthlyPayments
      .where((p) => p.parentRecurringId != null)
      .fold(0.0, (sum, p) => sum + p.amount);

  final walletSpending = monthlyPayments
      .where((p) => p.parentRecurringId == null && p.isWalleted)
      .fold(0.0, (sum, p) => sum + p.amount);

  final oneOffSpending = monthlyPayments
      .where((p) => p.parentRecurringId == null && !p.isWalleted)
      .fold(0.0, (sum, p) => sum + p.amount);

  final totalSpent = recurringSpending + walletSpending + oneOffSpending;

  final palette = generateSpendingPalette(category.color);

  final segments = [
    GaugeSegment(
      label: "Wallet", 
      amount: walletSpending, 
      color: palette.wallet,
    ),
    GaugeSegment(
      label: "Recurring", 
      amount: recurringSpending, 
      color: palette.recurring,
    ),
    GaugeSegment(
      label: "One-Off", 
      amount: oneOffSpending, 
      color: palette.oneOff,
    ),
  ];

  return CategoryGaugeData(
    segments: segments,
    totalBudget: projectedBudget,
    totalSpent: totalSpent,
  );
}