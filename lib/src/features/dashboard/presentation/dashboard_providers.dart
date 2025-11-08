import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dashboard_providers.g.dart';

// A simple data class to hold our summary calculations.
class MonthlySummary {
  const MonthlySummary({required this.totalBudget, required this.totalSpending});
  final double totalBudget;
  final double totalSpending;
  double get progress => (totalBudget > 0) ? (totalSpending / totalBudget).clamp(0.0, 1.0) : 0.0;
  double get amountRemaining => totalBudget - totalSpending;
}

@riverpod
Future<MonthlySummary> monthlySummary(Ref ref) async {
  final transactionLog = ref.watch(transactionLogProvider);
  final now = ref.watch(clockNotifierProvider).now();
  double totalMonthlyBudget = 0;

  // Calculate total spending for the current month
 return transactionLog.when(
    data: (log) {
      // --- The calculation now happens inside the data callback ---
      final startOfMonth = DateTime(now.year, now.month, 1);
      final totalMonthlySpending = log
          .whereType<OneOffPayment>()
          .where((p) => !p.date.isBefore(startOfMonth))
          .fold(0.0, (sum, p) => sum + p.amount);

      return MonthlySummary(
        totalBudget: totalMonthlyBudget,
        totalSpending: totalMonthlySpending,
      );
    },
    // Return a loading or error state if the transaction log isn't ready
    loading: () => const MonthlySummary(totalBudget: 0, totalSpending: 0),
    error: (e, s) => throw e, // Or handle the error appropriately
  );
}