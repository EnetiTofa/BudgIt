// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurringTransactionsHash() =>
    r'6204d40762f1c0427bf1d85e9f2f1bee85db6b03';

/// See also [RecurringTransactions].
@ProviderFor(RecurringTransactions)
final recurringTransactionsProvider = AutoDisposeAsyncNotifierProvider<
    RecurringTransactions, List<Transaction>>.internal(
  RecurringTransactions.new,
  name: r'recurringTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringTransactions = AutoDisposeAsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
