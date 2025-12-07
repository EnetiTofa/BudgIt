// lib/src/features/transactions/presentation/providers/recurring_transactions_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
// Removed unused repository import (since we get data from the provider now)
// import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';
// --- ADDED IMPORT ---
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

part 'recurring_transactions_provider.g.dart';

@riverpod
class RecurringTransactions extends _$RecurringTransactions {
  @override
  Future<List<Transaction>> build() async {
    final filter = ref.watch(logFilterProvider);
    
    // --- CHANGE: Watch the shared raw provider instead of fetching from DB ---
    final allTransactions = await ref.watch(rawTransactionsProvider.future);

    List<Transaction> recurringItems = allTransactions
        .where((t) => t is RecurringPayment || t is RecurringIncome)
        .toList();

    // 1. Apply the transaction type filter first.
    switch (filter.transactionTypeFilter) {
      case TransactionTypeFilter.payment:
        recurringItems = recurringItems.whereType<RecurringPayment>().toList();
        break;
      case TransactionTypeFilter.income:
        recurringItems = recurringItems.whereType<RecurringIncome>().toList();
        break;
      case TransactionTypeFilter.all:
        // No change needed
        break;
    }

    // 2. Apply the category filter if one is selected.
    if (filter.selectedCategoryIds.isNotEmpty) {
      recurringItems = recurringItems.where((transaction) {
        if (transaction is RecurringPayment) {
          // Keep the payment if its category is in the filter set.
          return filter.selectedCategoryIds.contains(transaction.category.id);
        }
        // Recurring income doesn't have categories, so it's filtered out.
        return false;
      }).toList();
    }

    return recurringItems;
  }

  Future<void> removeTransaction(String transactionId) async {
    await ref.read(addTransactionControllerProvider.notifier)
               .deleteTransaction(transactionId);
  }
}