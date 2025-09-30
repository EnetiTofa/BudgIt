// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_screen_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetScreenDataHash() => r'994e297eca47de7f1f1a6491de024940f34467e6';

/// This provider fetches all necessary data for the budget screen.
/// It ensures that both historical and progress data are loaded before the UI builds,
/// preventing the "zero-out" flicker on the timeline.
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetScreenDataRef = AutoDisposeFutureProviderRef<BudgetScreenData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
