// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allTransactionOccurrencesHash() =>
    r'f2d763b9803991c1b2023b1cf4526414a1438280';

/// See also [allTransactionOccurrences].
@ProviderFor(allTransactionOccurrences)
final allTransactionOccurrencesProvider =
    FutureProvider<List<Transaction>>.internal(
  allTransactionOccurrences,
  name: r'allTransactionOccurrencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTransactionOccurrencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTransactionOccurrencesRef = FutureProviderRef<List<Transaction>>;
String _$transactionLogHash() => r'7a90456a99fe97772ea192752d84f721476cc75f';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
