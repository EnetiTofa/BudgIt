import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'transaction_log_provider.g.dart';

// 1. CONVERTED TO A CLASS (AsyncNotifier)
@Riverpod(keepAlive: true)
class AllTransactionOccurrences extends _$AllTransactionOccurrences {
  /// The build method fetches the initial list of transactions.
  @override
  Future<List<Transaction>> build() async {
    final clock = ref.watch(clockProvider);
    final repository = ref.watch(transactionRepositoryProvider);
    final rawTransactions = await repository.getAllTransactions();

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
      final date = t is OneOffPayment ? t.date : (t as OneOffIncome).date;
      return date.isAfter(clock.now());
    });

    return occurrences;
  }

  /// 2. ADDED THIS METHOD
  /// This method synchronously removes a transaction from the UI
  /// and then deletes it from the database in the background.
  Future<void> removeTransaction(String transactionId) async {
    final currentTransactions = state.valueOrNull ?? [];
    
    // Update the state immediately with the item removed
    state = AsyncData(
      currentTransactions.where((tx) => tx.id != transactionId).toList()
    );

    // Perform the database deletion in the background
    // Note: We no longer need to invalidate here because this notifier manages its own state
    await ref.read(addTransactionControllerProvider.notifier)
               .deleteTransaction(transactionId);
  }
}


// 3. YOUR FILTERING PROVIDER REMAINS THE SAME
// This provider watches the class-based provider above and applies filters/sorting.
@riverpod
AsyncValue<List<Transaction>> transactionLog(Ref ref) {
  final occurrencesAsync = ref.watch(allTransactionOccurrencesProvider);
  final filter = ref.watch(logFilterProvider);

  if (occurrencesAsync.isLoading || occurrencesAsync.hasError) {
    return occurrencesAsync;
  }

  final occurrences = occurrencesAsync.value!;
  
  // First, we filter the list by transaction type.
  final List<Transaction> typeFilteredList;
  switch (filter.transactionTypeFilter) {
    case TransactionTypeFilter.payment:
      typeFilteredList = occurrences.whereType<OneOffPayment>().toList();
      break;
    case TransactionTypeFilter.income:
      typeFilteredList = occurrences.whereType<OneOffIncome>().toList();
      break;
    case TransactionTypeFilter.all:
      typeFilteredList = occurrences;
  }
  
  // --- THE FIX IS HERE ---
  // Use the 'typeFilteredList' here instead of the original 'occurrences' list.
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
        // Income transactions don't have categories, so they can't match.
        matchesCategory = false;
      }
    }
    return matchesQuery && matchesCategory;
  }).toList();

  // Sorting logic (unchanged)
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
        final dateA = a is OneOffPayment ? a.date : (a as OneOffIncome).date;
        final dateB = b is OneOffPayment ? b.date : (b as OneOffIncome).date;
        return dateB.compareTo(dateA); // Already descending
    }
  });

  return AsyncValue.data(filteredList);
}