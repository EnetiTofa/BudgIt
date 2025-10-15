import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'is_check_in_available_provider.g.dart';

DateTime _getDateFromTransaction(Transaction t) {
  if (t is OneOffPayment) return t.date;
  if (t is RecurringPayment) return t.startDate;
  if (t is OneOffIncome) return t.date;
  if (t is RecurringIncome) return t.startDate;
  // Fallback, though all transaction types should be covered.
  return DateTime.now();
}

@Riverpod(keepAlive: true)
Future<bool> isCheckInAvailable(IsCheckInAvailableRef ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();
  
  // Edge Case 1: No transactions at all.
  if (allTransactions.isEmpty) {
    return false;
  }

  final lastCheckInDate = await repository.getLastCheckInDate();
  final settingsNotifier = ref.read(settingsProvider.notifier);
  final checkInDay = await settingsNotifier.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();

  if (lastCheckInDate == null) {
    // Edge Case 2: New user with transactions but has never checked in.
    // Check-in should only be available after their first full week has passed.
    
    // 1. Find the date of the very first transaction.
    final firstTransactionDate = allTransactions
        .map(_getDateFromTransaction)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    // 2. Calculate the start of the week that contains that first transaction.
    final startOfFirstWeek = DateTime(
        firstTransactionDate.year,
        firstTransactionDate.month,
        firstTransactionDate.day - (firstTransactionDate.weekday - checkInDay + 7) % 7
    );
    
    // 3. The next check-in is available 7 days after the start of that first week.
    final firstCheckInAvailableDate = startOfFirstWeek.add(const Duration(days: 7));

    // 4. It's only available if the current time is past that date.
    return now.isAfter(firstCheckInAvailableDate);
  }

  // Standard case: User has checked in before.
  final startOfCurrentWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);
  
  // Check-in is available if the last one was before the start of the current week.
  return lastCheckInDate.isBefore(startOfCurrentWeek);
}