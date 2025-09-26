// lib/src/features/transactions/presentation/providers/recurring_transactions_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
// Add this import to access the controller
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';


part 'recurring_transactions_provider.g.dart';

@riverpod
class RecurringTransactions extends _$RecurringTransactions {
  @override
  Future<List<Transaction>> build() async {
    final filter = ref.watch(logFilterProvider);
    final repository = ref.watch(transactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions();

    final recurringItems = allTransactions
        .where((t) => t is RecurringPayment || t is RecurringIncome)
        .toList();

    // Apply the type filter
    switch (filter.transactionTypeFilter) {
      case TransactionTypeFilter.payment:
        return recurringItems.whereType<RecurringPayment>().toList();
      case TransactionTypeFilter.income:
        return recurringItems.whereType<RecurringIncome>().toList();
      case TransactionTypeFilter.all:
        return recurringItems;
    }
  }

  // --- UPDATED METHOD ---
  // This method now delegates the deletion to the central controller.
  Future<void> removeTransaction(String transactionId) async {
    // The controller will handle deleting from the repository and invalidating
    // all necessary providers (like the transaction log), which will trigger a rebuild.
    await ref.read(addTransactionControllerProvider.notifier)
               .deleteTransaction(transactionId);
  }
}