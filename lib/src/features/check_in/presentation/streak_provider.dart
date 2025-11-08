import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';

part 'streak_provider.g.dart';

@riverpod
Future<int> checkInStreak(Ref ref) {
  return ref.watch(transactionRepositoryProvider).getCheckInStreak();
}