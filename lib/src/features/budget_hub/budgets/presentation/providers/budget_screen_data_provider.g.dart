// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_screen_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetScreenDataHash() => r'8c8c81d054e7094934115d2c907af8848dd6e609';

/// This provider fetches all necessary data for the budget screen.
/// It ensures that all data is loaded before the UI builds,
/// preventing flickering on month changes.
///
/// Copied from [budgetScreenData].
@ProviderFor(budgetScreenData)
final budgetScreenDataProvider =
    AutoDisposeFutureProvider<BudgetScreenData>.internal(
  budgetScreenData,
  name: r'budgetScreenDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetScreenDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BudgetScreenDataRef = AutoDisposeFutureProviderRef<BudgetScreenData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
