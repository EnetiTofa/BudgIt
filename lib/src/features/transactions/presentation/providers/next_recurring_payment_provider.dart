// lib/src/features/transactions/presentation/providers/next_recurring_payment_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'next_recurring_payment_provider.g.dart';

@riverpod
Future<PaymentOccurrence?> nextRecurringPayment(
  NextRecurringPaymentRef ref, {
  required String categoryId,
}) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();
  final now = ref.watch(clockNotifierProvider).now();
  final today = DateTime(now.year, now.month, now.day);

  // 1. Get all recurring payment rules for this category
  final categoryRecurringPayments = allTransactions
      .whereType<RecurringPayment>()
      .where((p) => p.category.id == categoryId)
      .toList();

  if (categoryRecurringPayments.isEmpty) {
    return null;
  }

  final List<PaymentOccurrence> nextOccurrences = [];

  // 2. For each rule, find its first occurrence on or after today
  for (final rule in categoryRecurringPayments) {
    if (rule.endDate != null && rule.endDate!.isBefore(today)) {
      continue; // This rule has already ended
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
    
    // Now `nextDate` is the upcoming occurrence. Add it if it's valid.
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

  // 3. Sort all potential next occurrences to find the one that is soonest
  nextOccurrences.sort((a, b) => a.date.compareTo(b.date));
  
  return nextOccurrences.first;
}