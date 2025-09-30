// lib/src/features/budgets/presentation/providers/category_gauge_data_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/category_gauge.dart';

part 'category_gauge_data_provider.g.dart';

/// A data class to hold all information needed by the CategoryGauge widget.
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

  // Define the timeframe for the selected month
  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);

  // Filter payments for the specific category and month
  final monthlyPayments = allOccurrences
      .whereType<OneOffPayment>()
      .where((p) =>
          p.category.id == category.id &&
          !p.date.isBefore(timeFrameStartDate) &&
          !p.date.isAfter(timeFrameEndDate))
      .toList();

  // Calculate the projected budget for the month's length
  final timeFrameDays = timeFrameEndDate.day;
  final double dailyRate = (category.budgetAmount * 12) / 365.25;
  final projectedBudget = dailyRate * timeFrameDays;

  // --- UPDATED LOGIC ---
  final recurringSpending = monthlyPayments
      .where((p) => p.parentRecurringId != null)
      .fold(0.0, (sum, p) => sum + p.amount);

  final walletSpending = monthlyPayments
      .where((p) => p.parentRecurringId == null && p.isWalleted)
      .fold(0.0, (sum, p) => sum + p.amount);

  final oneOffSpending = monthlyPayments
      .where((p) => p.parentRecurringId == null && !p.isWalleted)
      .fold(0.0, (sum, p) => sum + p.amount);
  // ---------------------

  final totalSpent = recurringSpending + walletSpending + oneOffSpending;

  // Create color palette based on the category color
  final lightestColor = category.color;
  final hslColor = HSLColor.fromColor(lightestColor);
  final mediumColor = hslColor
      .withLightness(hslColor.lightness * 0.8)
      .withSaturation(hslColor.saturation * 0.82)
      .toColor();
  final darkestColor = hslColor
      .withLightness(hslColor.lightness * 0.65)
      .withSaturation(hslColor.saturation * 0.78)
      .toColor();

  // Create the segments for the gauge
  final segments = [
    GaugeSegment("Recurring", recurringSpending, lightestColor),
    GaugeSegment("Wallet", walletSpending, mediumColor),
    GaugeSegment("One-Off", oneOffSpending, darkestColor),
  ];

  return CategoryGaugeData(
    segments: segments,
    totalBudget: projectedBudget,
    totalSpent: totalSpent,
  );
}