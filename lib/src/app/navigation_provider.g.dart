// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mainPageIndexHash() => r'1127f9195c5f75cdea59520cb5e70237d9110dad';

/// This provider holds the index of the currently selected page
/// in the main AppShell's BottomAppBar.
///
/// Copied from [MainPageIndex].
@ProviderFor(MainPageIndex)
final mainPageIndexProvider = NotifierProvider<MainPageIndex, int>.internal(
  MainPageIndex.new,
  name: r'mainPageIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mainPageIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MainPageIndex = Notifier<int>;
String _$transactionHubTabIndexHash() =>
    r'b2f7a7c86d25a1a59726f3e4b606704ddc449c8d';

/// This provider can control the selected tab within the Transaction Hub
/// (e.g., 0 for the Log, 1 for Recurring).
///
/// Copied from [TransactionHubTabIndex].
@ProviderFor(TransactionHubTabIndex)
final transactionHubTabIndexProvider =
    NotifierProvider<TransactionHubTabIndex, int>.internal(
  TransactionHubTabIndex.new,
  name: r'transactionHubTabIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionHubTabIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionHubTabIndex = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
