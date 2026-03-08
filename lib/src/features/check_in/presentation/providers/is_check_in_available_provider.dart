import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/utils/date_utils.dart';

part 'is_check_in_available_provider.g.dart';

DateTime _getCreatedAtFromTransaction(Transaction t) {
  if (t is OneOffPayment) return t.createdAt;
  if (t is RecurringPayment) return t.createdAt;
  if (t is OneOffIncome) return t.createdAt;
  if (t is RecurringIncome) return t.createdAt;
  return DateTime.now();
}

@Riverpod(keepAlive: true)
Future<CheckInType> isCheckInAvailable(Ref ref) async {
  final settingsRepo = await ref.watch(settingsProvider.future);

  // 1. FIRST-TIME CHECK
  if (!settingsRepo.getHasCompletedFirstCheckIn()) {
    return CheckInType.firstTime;
  }

  // 2. TRANSACTIONS CHECK
  final repository = ref.watch(transactionRepositoryProvider);
  final allTransactions = await repository.getAllTransactions();
  if (allTransactions.isEmpty) {
    return CheckInType.none;
  }

  final lastCheckInDate = await repository.getLastCheckInDate();
  final lastMonthlyCheckInDate = settingsRepo.getLastMonthlyCheckInDate();
  final checkInDay = settingsRepo.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();

  // Find the most recent midnight occurrence of your chosen check-in day.
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );

  bool isDue = false;
  final nowDateOnly = now.dateOnly;
  final startOfWeekDateOnly = startOfCurrentWeek.dateOnly;
  final lastCheckInDateOnly = lastCheckInDate?.dateOnly;

  // RULE A: If today IS the check-in day, allow it (unless already done today).
  if (now.weekday == checkInDay) {
    if (lastCheckInDateOnly == null ||
        !DateUtils.isSameDay(lastCheckInDateOnly, nowDateOnly)) {
      isDue = true;
    }
  }
  // RULE B: Edge case (Should be caught by First Time now, but kept for safety)
  else if (lastCheckInDateOnly == null) {
    final firstTxDate = allTransactions
        .map(_getCreatedAtFromTransaction)
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .dateOnly;
    if (firstTxDate.isBefore(startOfWeekDateOnly)) {
      isDue = true;
    }
  }
  // RULE C: If they missed the check-in for the current active week
  else if (lastCheckInDateOnly.isBefore(startOfWeekDateOnly)) {
    isDue = true;
  }

  if (!isDue) {
    return CheckInType.none;
  }

  // --- MONTHLY VS WEEKLY CALCULATION ---
  // If we reach here, a check-in is due. We use `startOfCurrentWeek` to determine
  // which month this check-in belongs to.

  // Have they already done a monthly check-in for this specific month?
  if (lastMonthlyCheckInDate == null ||
      lastMonthlyCheckInDate.month != startOfWeekDateOnly.month ||
      lastMonthlyCheckInDate.year != startOfWeekDateOnly.year) {
    // Find what the FIRST check-in day of this target month is.
    final firstCheckInOfTargetMonth = getFirstCheckInDayOfMonth(
      startOfWeekDateOnly.year,
      startOfWeekDateOnly.month,
      checkInDay,
    );

    // Only prompt for a Monthly check-in if the week we are checking in for
    // is ON or AFTER the first check-in day of the month.
    if (!startOfWeekDateOnly.isBefore(firstCheckInOfTargetMonth.dateOnly)) {
      return CheckInType.monthly;
    }
  }

  // Otherwise, it's just a regular weekly check-in!
  return CheckInType.weekly;
}
