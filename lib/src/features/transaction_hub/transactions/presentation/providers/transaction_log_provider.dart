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

@Riverpod(keepAlive: true)
Future<List<Transaction>> rawTransactions(RawTransactionsRef ref) {
  return ref.watch(transactionRepositoryProvider).getAllTransactions();
}

@Riverpod(keepAlive: true)
class AllTransactionOccurrences extends _$AllTransactionOccurrences {
  @override
  Future<List<Transaction>> build() async {
    final clock = ref.watch(clockNotifierProvider);
    final rawTransactions = await ref.watch(rawTransactionsProvider.future);

    final List<Transaction> occurrences = [];
    for (final transaction in rawTransactions) {
      if (transaction is OneOffPayment || transaction is OneOffIncome) {
        occurrences.add(transaction);
      } else if (transaction is RecurringPayment) {
        occurrences.addAll(
          transaction.generateOccurrences(upToDate: clock.now()),
        );
      } else if (transaction is RecurringIncome) {
        occurrences.addAll(
          transaction.generateOccurrences(upToDate: clock.now()),
        );
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

  Future<void> removeTransaction(String transactionId) async {
    final currentTransactions = state.valueOrNull ?? [];

    state = AsyncData(
      currentTransactions.where((tx) => tx.id != transactionId).toList(),
    );

    await ref
        .read(addTransactionControllerProvider.notifier)
        .deleteTransaction(transactionId);
  }
}

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
      typeFilteredList = occurrences
          .where((t) => t is OneOffPayment || t is PaymentOccurrence)
          .toList();
      break;
    case TransactionTypeFilter.income:
      typeFilteredList = occurrences
          .where((t) => t is OneOffIncome || t is IncomeOccurrence)
          .toList();
      break;
    case TransactionTypeFilter.all:
      typeFilteredList = occurrences;
  }

  final filteredList = typeFilteredList.where((tx) {
    // --- 1. SEARCH QUERY ---
    final query = filter.searchQuery.toLowerCase();
    bool matchesQuery = true;
    if (query.isNotEmpty) {
      if (tx is OneOffPayment) {
        matchesQuery =
            tx.itemName.toLowerCase().startsWith(query) ||
            tx.category.name.toLowerCase().startsWith(query);
      } else if (tx is OneOffIncome) {
        matchesQuery = tx.source.toLowerCase().startsWith(query);
      }
    }

    // --- 2. CATEGORY MATCH ---
    bool matchesCategory = true;
    if (filter.selectedCategoryIds.isNotEmpty) {
      if (tx is OneOffPayment) {
        matchesCategory = filter.selectedCategoryIds.contains(tx.category.id);
      } else {
        matchesCategory = false;
      }
    }

    // --- 3. ADDED: DATE RANGE MATCH ---
    bool matchesDate = true;
    if (filter.startDate != null || filter.endDate != null) {
      // Changed && to ||
      try {
        final txDate = (tx as dynamic).date as DateTime;

        // If a start date exists, ensure transaction is AFTER or ON the start date
        if (filter.startDate != null) {
          final startOfDay = DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          );
          if (txDate.isBefore(startOfDay)) matchesDate = false;
        }

        // If an end date exists, ensure transaction is BEFORE or ON the end date
        if (filter.endDate != null) {
          final endOfDay = filter.endDate!.add(
            const Duration(hours: 23, minutes: 59, seconds: 59),
          );
          if (txDate.isAfter(endOfDay)) matchesDate = false;
        }
      } catch (_) {
        matchesDate = false;
      }
    }

    return matchesQuery && matchesCategory && matchesDate;
  }).toList();

  filteredList.sort((a, b) {
    switch (filter.sortBy) {
      // --- ADDED: SIZE (AMOUNT) SORT ---
      case SortBy.amount:
        double amountA = 0;
        double amountB = 0;
        try {
          amountA = (a as dynamic).amount as double;
        } catch (_) {}
        try {
          amountB = (b as dynamic).amount as double;
        } catch (_) {}
        // Descending order (Largest amount at the top)
        return amountB.compareTo(amountA);

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

        // Safely extract dates for all transaction types
        try {
          dateA = (a as dynamic).date as DateTime?;
        } catch (_) {}
        try {
          dateB = (b as dynamic).date as DateTime?;
        } catch (_) {}

        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
    }
  });

  return AsyncValue.data(filteredList);
}
