// lib/src/features/transactions/presentation/providers/next_recurring_payment_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';
// Import the new raw transactions provider
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

part 'next_recurring_payment_provider.g.dart';

// --- CHANGED: Now a synchronous Provider (AutoDispose) ---
@riverpod
PaymentOccurrence? nextRecurringPayment(
  NextRecurringPaymentRef ref, {
  required String categoryId,
}) {
  // 1. Synchronously watch the raw data
  final rawTransactionsAsync = ref.watch(rawTransactionsProvider);
  
  // If data isn't loaded yet, return null (the UI will handle "No data" or wait)
  // But practically, in the dashboard, this is already loaded.
  if (!rawTransactionsAsync.hasValue) {
    return null; 
  }

  final allTransactions = rawTransactionsAsync.value!;
  final now = ref.watch(clockNotifierProvider).now();
  final today = DateTime(now.year, now.month, now.day);

  // 2. Filter synchronously
  final categoryRecurringPayments = allTransactions
      .whereType<RecurringPayment>()
      .where((p) => p.category.id == categoryId)
      .toList();

  if (categoryRecurringPayments.isEmpty) {
    return null;
  }

  final List<PaymentOccurrence> nextOccurrences = [];

  // 3. Calculation Logic (Unchanged)
  for (final rule in categoryRecurringPayments) {
    if (rule.endDate != null && rule.endDate!.isBefore(today)) {
      continue;
    }

    DateTime nextDate = rule.startDate;
    while (nextDate.isBefore(today)) {
      switch (rule.recurrence) {
        case RecurrencePeriod.daily:
          nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + rule.recurrenceFrequency);
          break;
        case RecurrencePeriod.weekly:
          nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + (7 * rule.recurrenceFrequency));
          break;
        case RecurrencePeriod.monthly:
          nextDate = DateTime(nextDate.year, nextDate.month + rule.recurrenceFrequency, nextDate.day);
          break;
        case RecurrencePeriod.yearly:
          nextDate = DateTime(nextDate.year + rule.recurrenceFrequency, nextDate.month, nextDate.day);
          break;
      }
    }
    
    if (rule.endDate == null || !nextDate.isAfter(rule.endDate!)) {
        nextOccurrences.add(PaymentOccurrence(
          id: '${rule.id}_${nextDate.toIso8601String()}',
          parentRecurringId: rule.id,
          amount: rule.amount,
          notes: rule.notes,
          createdAt: rule.createdAt,
          date: nextDate,
          itemName: rule.paymentName,
          store: rule.payee,
          category: rule.category,
          iconCodePoint: rule.iconCodePoint,
          iconFontFamily: rule.iconFontFamily,
        ));
    }
  }

  if (nextOccurrences.isEmpty) {
    return null;
  }

  nextOccurrences.sort((a, b) => a.date.compareTo(b.date));
  
  return nextOccurrences.first;
}