// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rawTransactionsHash() => r'463b3f89c9492934e2e414781fcc2b2d20115f49';

/// See also [rawTransactions].
@ProviderFor(rawTransactions)
final rawTransactionsProvider = FutureProvider<List<Transaction>>.internal(
  rawTransactions,
  name: r'rawTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rawTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RawTransactionsRef = FutureProviderRef<List<Transaction>>;
String _$transactionLogHash() => r'cbac92fcf65027e8aaff3ec04e15bc0cc59d0351';

/// See also [transactionLog].
@ProviderFor(transactionLog)
final transactionLogProvider =
    AutoDisposeProvider<AsyncValue<List<Transaction>>>.internal(
  transactionLog,
  name: r'transactionLogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionLogRef
    = AutoDisposeProviderRef<AsyncValue<List<Transaction>>>;
String _$allTransactionOccurrencesHash() =>
    r'22a9d2d490d0912f685d6d943641981e8c1474f5';

/// See also [AllTransactionOccurrences].
@ProviderFor(AllTransactionOccurrences)
final allTransactionOccurrencesProvider = AsyncNotifierProvider<
    AllTransactionOccurrences, List<Transaction>>.internal(
  AllTransactionOccurrences.new,
  name: r'allTransactionOccurrencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTransactionOccurrencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllTransactionOccurrences = AsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
