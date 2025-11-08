// lib/src/features/budgets/presentation/providers/category_gauge_data_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/category_gauge.dart';
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

@riverpod
Future<CategoryGaugeData> categoryGaugeData(
  CategoryGaugeDataRef ref, {
  required Category category,
  required DateTime month,
}) async {
  final allOccurrences =
      await ref.watch(allTransactionOccurrencesProvider.future);

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

  // --- MODIFICATION START ---
  // Reordered the segments to Wallet, Recurring, One-Off
  final segments = [
    GaugeSegment("Wallet", walletSpending, palette.wallet),
    GaugeSegment("Recurring", recurringSpending, palette.recurring),
    GaugeSegment("One-Off", oneOffSpending, palette.oneOff),
  ];
  // --- MODIFICATION END ---

  return CategoryGaugeData(
    segments: segments,
    totalBudget: projectedBudget,
    totalSpent: totalSpent,
  );
}