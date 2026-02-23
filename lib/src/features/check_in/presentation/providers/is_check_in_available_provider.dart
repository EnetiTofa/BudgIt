// lib/src/features/check_in/presentation/is_check_in_available_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'is_check_in_available_provider.g.dart';

DateTime _getCreatedAtFromTransaction(Transaction t) {
  if (t is OneOffPayment) return t.createdAt;
  if (t is RecurringPayment) return t.createdAt;
  if (t is OneOffIncome) return t.createdAt;
  if (t is RecurringIncome) return t.createdAt;
  return DateTime.now();
}

@Riverpod(keepAlive: true)
Future<bool> isCheckInAvailable(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();
  
  // RULE 1: You cannot check in if you have no transactions to review.
  if (allTransactions.isEmpty) {
    return false;
  }

  final lastCheckInDate = await repository.getLastCheckInDate();
  final settingsRepo = await ref.watch(settingsProvider.future);
  final checkInDay = settingsRepo.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();

  // Find the most recent midnight occurrence of your chosen check-in day.
  // (If today IS your check-in day, this returns today at 00:00:00).
  final startOfCurrentWeek = DateTime(
    now.year, 
    now.month, 
    now.day - (now.weekday - checkInDay + 7) % 7
  );

  // RULE 2: If today IS the check-in day, allow it (unless already done today).
  if (now.weekday == checkInDay) {
    if (lastCheckInDate != null && DateUtils.isSameDay(lastCheckInDate, now)) {
      return false; 
    }
    return true;
  }

  // RULE 3: If the user reset their check-in data (lastCheckInDate is null)
  if (lastCheckInDate == null) {
    final firstTxDate = allTransactions
        .map(_getCreatedAtFromTransaction)
        .reduce((a, b) => a.isBefore(b) ? a : b);
        
    // Allow check-in if their oldest transaction happened before the most recent check-in day.
    return firstTxDate.isBefore(startOfCurrentWeek);
  }

  // RULE 4: Standard check - Did they check in before the most recent boundary?
  return lastCheckInDate.isBefore(startOfCurrentWeek);
}