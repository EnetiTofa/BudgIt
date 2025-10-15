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
      // Safely get the date from either type
      final DateTime date;
      if (t is OneOffPayment) {
        date = t.date;
      } else if (t is OneOffIncome) {
        date = t.date;
      } else {
        // If the transaction type doesn't have a date, don't remove it.
        // Or handle as an error, depending on your logic.
        return false;
      }
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
        // Income transactions don't have categories, so they can't match.
        matchesCategory = false;
      }
    }
    return matchesQuery && matchesCategory;
  }).toList();

  // --- THE FIX IS HERE ---
  // Sorting logic now correctly compares DateTime objects.
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

        // More robust way to get the date from transaction 'a'
        if (a is OneOffPayment) {
          dateA = a.date;
        } else if (a is OneOffIncome) {
          dateA = a.date;
        }

        // More robust way to get the date from transaction 'b'
        if (b is OneOffPayment) {
          dateB = b.date;
        } else if (b is OneOffIncome) {
          dateB = b.date;
        }

        // Failsafe in case one of the dates is null
        if (dateA == null || dateB == null) {
          return 0; // Don't change order if a date is missing
        }

        // The actual comparison
        return dateB.compareTo(dateA);
    }
  });

  return AsyncValue.data(filteredList);
}
