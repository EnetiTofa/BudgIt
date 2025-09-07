import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'transaction_log_provider.g.dart';

@riverpod
Future<List<Transaction>> transactionLog(Ref ref) async {
  final clock = ref.watch(clockProvider);
  final repository = ref.watch(transactionRepositoryProvider);
  final rawTransactions = await repository.getAllTransactions();

  final List<Transaction> log = [];

  for (final transaction in rawTransactions) {
    if (transaction is OneOffPayment || transaction is OneOffIncome) {
      log.add(transaction);
    } else if (transaction is RecurringPayment) {
      log.addAll(transaction.generateOccurrences(upToDate: clock.now()));
    } else if (transaction is RecurringIncome) { // <-- Add this block
      log.addAll(transaction.generateOccurrences(upToDate: clock.now()));
    }
  }

  // A helper function to get the date from any transaction type
  DateTime getDate(Transaction t) {
    if (t is OneOffPayment) return t.date;
    if (t is OneOffIncome) return t.date;
    // Should not happen in this log, but good for safety
    return (t as RecurringPayment).startDate;
  }

  // Filter out any future transactions
  log.removeWhere((t) => getDate(t).isAfter(clock.now()));
  
  // Sort the final log by date, descending.
  log.sort((a, b) => getDate(b).compareTo(getDate(a)));

  return log;
}