// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionLogHash() => r'69f708b0d1dbd136f54d84e0c7abfd1148505db6';

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
    r'9a91f70a02a2e2dc284f4af26a17d0bc347a8c41';

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
