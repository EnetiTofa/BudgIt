// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$averageWeeklySavingsHash() =>
    r'e34bc67f4130b05012ccc61f4e297f0f75e8bca3';

/// The "Financial Analyst" provider.
/// Calculates the user's average weekly unspent wallet funds based on historical data.
///
/// Copied from [averageWeeklySavings].
@ProviderFor(averageWeeklySavings)
final averageWeeklySavingsProvider = AutoDisposeFutureProvider<double>.internal(
  averageWeeklySavings,
  name: r'averageWeeklySavingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$averageWeeklySavingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AverageWeeklySavingsRef = AutoDisposeFutureProviderRef<double>;
String _$totalSavingsHash() => r'd4ce2abe82e3aa1e0b1da051b5a353eef0b025cf';

/// Fetches total savings from the repository (snapshot data).
///
/// Copied from [totalSavings].
@ProviderFor(totalSavings)
final totalSavingsProvider = AutoDisposeFutureProvider<double>.internal(
  totalSavings,
  name: r'totalSavingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalSavingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalSavingsRef = AutoDisposeFutureProviderRef<double>;
String _$potentialWeeklySavingsHash() =>
    r'a072cdc653511ed3014e1d82db337876dc757ced';

/// The "Motivator" provider.
/// Calculates the potential weekly savings if the user sticks to a simple rule.
///
/// Copied from [potentialWeeklySavings].
@ProviderFor(potentialWeeklySavings)
final potentialWeeklySavingsProvider =
    AutoDisposeFutureProvider<double>.internal(
  potentialWeeklySavings,
  name: r'potentialWeeklySavingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$potentialWeeklySavingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PotentialWeeklySavingsRef = AutoDisposeFutureProviderRef<double>;
String _$savingsGoalHash() => r'853e4e0324f30421c2b359db2db1ad2bbf2ec212';

/// See also [savingsGoal].
@ProviderFor(savingsGoal)
final savingsGoalProvider = AutoDisposeFutureProvider<SavingsGoal?>.internal(
  savingsGoal,
  name: r'savingsGoalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$savingsGoalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavingsGoalRef = AutoDisposeFutureProviderRef<SavingsGoal?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
