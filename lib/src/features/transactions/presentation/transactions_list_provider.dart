import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';

part 'transactions_list_provider.g.dart';

// This provider will fetch the list of all transactions.
@riverpod
Future<List<Transaction>> transactionsList(Ref ref) async {
  // Get the repository.
  final repository = ref.watch(transactionRepositoryProvider);
  // Fetch the data and return it.
  return repository.getAllTransactions();
}