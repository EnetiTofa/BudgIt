// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionLogRef
    = AutoDisposeProviderRef<AsyncValue<List<Transaction>>>;
String _$allTransactionOccurrencesHash() =>
    r'7a7ba5191199cc833710dd03fba8cbef8506b68f';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
