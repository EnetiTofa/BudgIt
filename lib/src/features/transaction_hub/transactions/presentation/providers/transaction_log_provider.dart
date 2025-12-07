// lib/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'transaction_log_provider.g.dart';

// --- NEW: Single Source of Truth for Raw Data ---
@Riverpod(keepAlive: true)
Future<List<Transaction>> rawTransactions(RawTransactionsRef ref) {
  return ref.watch(transactionRepositoryProvider).getAllTransactions();
}

// 1. CONVERTED TO A CLASS (AsyncNotifier)
@Riverpod(keepAlive: true)
class AllTransactionOccurrences extends _$AllTransactionOccurrences {
  /// The build method fetches the initial list of transactions.
  @override
  Future<List<Transaction>> build() async {
    final clock = ref.watch(clockNotifierProvider);
    
    // --- CHANGE: Watch the raw provider instead of repo directly ---
    // This allows other providers to share the same data source without re-fetching.
    final rawTransactions = await ref.watch(rawTransactionsProvider.future);

    final List<Transaction> occurrences = [];
    for (final transaction in rawTransactions) {
      if (transaction is OneOffPayment || transaction is OneOffIncome) {
        occurrences.add(transaction);
      } else if (transaction is RecurringPayment) {
        occurrences.addAll(transaction.generateOccurrences(upToDate: clock.now()));
      } else if (transaction is RecurringIncome) {
        occurrences.addAll(transaction.generateOccurrences(upToDate: clock.now()));
      }
    }

    occurrences.removeWhere((t) {
      final DateTime date;
      if (t is OneOffPayment) {
        date = t.date;
      } else if (t is OneOffIncome) {
        date = t.date;
      } else {
        return false;
      }
      return date.isAfter(clock.now());
    });

    return occurrences;
  }

  /// This method synchronously removes a transaction from the UI
  /// and then deletes it from the database in the background.
  Future<void> removeTransaction(String transactionId) async {
    final currentTransactions = state.valueOrNull ?? [];
    
    // Update the state immediately with the item removed
    state = AsyncData(
      currentTransactions.where((tx) => tx.id != transactionId).toList()
    );

    // Perform the database deletion in the background
    await ref.read(addTransactionControllerProvider.notifier)
               .deleteTransaction(transactionId);
    
    // Note: The controller will likely trigger a refresh of rawTransactionsProvider,
    // which will eventually trigger a rebuild of this provider too, ensuring consistency.
  }
}

// 3. YOUR FILTERING PROVIDER REMAINS THE SAME
@riverpod
AsyncValue<List<Transaction>> transactionLog(Ref ref) {
  final occurrencesAsync = ref.watch(allTransactionOccurrencesProvider);
  final filter = ref.watch(logFilterProvider);

  if (occurrencesAsync.isLoading || occurrencesAsync.hasError) {
    return occurrencesAsync;
  }

  final occurrences = occurrencesAsync.value!;
  
  final List<Transaction> typeFilteredList;
  switch (filter.transactionTypeFilter) {
    case TransactionTypeFilter.payment:
      typeFilteredList = occurrences.where((t) => t is OneOffPayment || t is PaymentOccurrence).toList();
      break;
    case TransactionTypeFilter.income:
      typeFilteredList = occurrences.where((t) => t is OneOffIncome || t is IncomeOccurrence).toList();
      break;
    case TransactionTypeFilter.all:
      typeFilteredList = occurrences;
  }
  
  final filteredList = typeFilteredList.where((tx) {
    final query = filter.searchQuery.toLowerCase();
    bool matchesQuery = true;
    if (query.isNotEmpty) {
      if (tx is OneOffPayment) {
        matchesQuery = tx.itemName.toLowerCase().startsWith(query) ||
                      tx.category.name.toLowerCase().startsWith(query);
      } else if (tx is OneOffIncome) {
        matchesQuery = tx.source.toLowerCase().startsWith(query);
      }
    }

    bool matchesCategory = true;
    if (filter.selectedCategoryIds.isNotEmpty) {
      if (tx is OneOffPayment) {
        matchesCategory = filter.selectedCategoryIds.contains(tx.category.id);
      } else {
        matchesCategory = false;
      }
    }
    return matchesQuery && matchesCategory;
  }).toList();

  filteredList.sort((a, b) {
    switch (filter.sortBy) {
      case SortBy.category:
        final catA = a is OneOffPayment ? a.category.name : 'Income';
        final catB = b is OneOffPayment ? b.category.name : 'Income';
        return catA.compareTo(catB);
      case SortBy.store:
        final storeA = a is OneOffPayment ? a.store : 'Income';
        final storeB = b is OneOffPayment ? b.store : 'Income';
        return storeA.compareTo(storeB);
        
      case SortBy.date:
        DateTime? dateA;
        DateTime? dateB;

        if (a is OneOffPayment) {
          dateA = a.date;
        } else if (a is OneOffIncome) {
          dateA = a.date;
        }

        if (b is OneOffPayment) {
          dateB = b.date;
        } else if (b is OneOffIncome) {
          dateB = b.date;
        }

        if (dateA == null || dateB == null) {
          return 0;
        }

        return dateB.compareTo(dateA);
    }
  });

  return AsyncValue.data(filteredList);
}