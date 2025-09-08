import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'transaction_log_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Transaction>> allTransactionOccurrences(Ref ref) async {
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

@riverpod
AsyncValue<List<Transaction>> transactionLog(Ref ref) {
  // Get the AsyncValue from the fetcher provider
  final occurrencesAsync = ref.watch(allTransactionOccurrencesProvider);
  final filter = ref.watch(logFilterProvider);

  // If the main list is loading or has an error, pass that state along to the UI.
  if (occurrencesAsync.isLoading || occurrencesAsync.hasError) {
    return occurrencesAsync;
  }

  // If we have data, perform the synchronous filtering.
  final occurrences = occurrencesAsync.value!;
  final filteredList = occurrences.where((tx) {
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

  // --- This is the missing sorting logic ---
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
        return dateA.compareTo(dateB);
    }
  });

  return AsyncValue.data(filteredList);
}