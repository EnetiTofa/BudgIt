// lib/src/features/check_in/presentation/is_check_in_available_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'is_check_in_available_provider.g.dart';

DateTime _getCreatedAtFromTransaction(Transaction t) {
  // ... (this function remains unchanged)
  if (t is OneOffPayment) return t.createdAt;
  if (t is RecurringPayment) return t.createdAt;
  if (t is OneOffIncome) return t.createdAt;
  if (t is RecurringIncome) return t.createdAt;
  return DateTime.now();
}

@Riverpod(keepAlive: true)
Future<bool> isCheckInAvailable(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();
  
  if (allTransactions.isEmpty) {
    return false;
  }

  final lastCheckInDate = await repository.getLastCheckInDate();
  
  // --- FIX: Await the provider's future to ensure it's initialized ---
  // This line pauses execution until the SettingsRepository is ready.
  final settingsRepo = await ref.watch(settingsProvider.future);
  // Now it's safe to get the check-in day.
  final checkInDay = settingsRepo.getCheckInDay();
  
  final now = ref.watch(clockNotifierProvider).now();

  if (lastCheckInDate == null) {
    // ... (The rest of the function remains unchanged)
    final firstTransactionCreationDate = allTransactions
        .map(_getCreatedAtFromTransaction)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final startOfFirstUsageWeek = DateTime(
        firstTransactionCreationDate.year,
        firstTransactionCreationDate.month,
        firstTransactionCreationDate.day - (firstTransactionCreationDate.weekday - checkInDay + 7) % 7
    );
    
    final firstCheckInAvailableDate = startOfFirstUsageWeek.add(const Duration(days: 7));

    return now.isAfter(firstCheckInAvailableDate);
  }

  final startOfCurrentWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);
  
  return lastCheckInDate.isBefore(startOfCurrentWeek);
}