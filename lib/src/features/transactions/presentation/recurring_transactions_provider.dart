import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';

part 'recurring_transactions_provider.g.dart';

@riverpod
Future<List<Transaction>> recurringTransactions(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();

  // Filter the list to only include recurring items
  return allTransactions
      .where((t) => t is RecurringPayment || t is RecurringIncome)
      .toList();
}