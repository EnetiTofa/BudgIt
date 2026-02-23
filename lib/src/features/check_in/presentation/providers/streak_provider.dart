// lib/src/features/check_in/presentation/streak_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';

part 'streak_provider.g.dart';

@riverpod
Future<int> checkInStreak(Ref ref) {
  return ref.watch(transactionRepositoryProvider).getCheckInStreak();
}

// THIS IS THE NEW PROVIDER FOR THE WIDGET
@riverpod
Future<Set<DateTime>> checkInHistory(Ref ref) async {
  final historyList = await ref.watch(transactionRepositoryProvider).getSuccessfulCheckInDates();
  return historyList.toSet();
}