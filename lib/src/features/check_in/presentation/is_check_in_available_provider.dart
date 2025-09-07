import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'is_check_in_available_provider.g.dart';

@riverpod
Future<bool> isCheckInAvailable(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final lastCheckInDate = await repository.getLastCheckInDate();
  
  if (lastCheckInDate == null) return true; // If never run, it's available

  final settingsNotifier = ref.read(settingsProvider.notifier);
  final checkInDay = await settingsNotifier.getCheckInDay();
  final now = ref.watch(clockProvider).now();
  
  final startOfCurrentWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);

  // If the last check-in was before the start of the current week, it's available.
  final isAvailable = lastCheckInDate.isBefore(startOfCurrentWeek);
  
  return isAvailable;
}