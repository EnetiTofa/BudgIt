import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/wallet/domain/wallet_data.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'wallet_provider.g.dart';

@riverpod
Future<WalletData> walletData(Ref ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(transactionLogProvider.future);
  final now = ref.watch(clockProvider).now();

  // --- Date Calculations ---
  // Monday is 1, Sunday is 7. We calculate the date of the most recent Monday at midnight.
  final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final startOfToday = DateTime(now.year, now.month, now.day);
  
  // --- Data Filtering & Aggregation ---
  final totalWalletBudget = categories.fold(0.0, (sum, cat) => sum + (cat.walletAmount ?? 0.0));
  
  final walletTransactionsThisWeek = transactionLog
      .whereType<OneOffPayment>()
      .where((p) => p.isWalleted && !p.date.isBefore(startOfWeek))
      .toList();
      
  final spentCompletedDays = walletTransactionsThisWeek
      .where((p) => p.date.isBefore(startOfToday))
      .fold(0.0, (sum, p) => sum + p.amount);
      
  final spendingToday = walletTransactionsThisWeek
      .where((p) => !p.date.isBefore(startOfToday))
      .fold(0.0, (sum, p) => sum + p.amount);

  return WalletData(
    totalWalletBudget: totalWalletBudget,
    spentCompletedDays: spentCompletedDays,
    spendingToday: spendingToday,
    completedDays: now.weekday - 1,
  );
}