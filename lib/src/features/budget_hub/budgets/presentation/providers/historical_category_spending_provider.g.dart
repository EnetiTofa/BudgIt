// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_category_spending_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historicalCategorySpendingHash() =>
    r'80bee6d0c04031f3918ecbe16f60c7b997e01508';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [historicalCategorySpending].
@ProviderFor(historicalCategorySpending)
const historicalCategorySpendingProvider = HistoricalCategorySpendingFamily();

/// See also [historicalCategorySpending].
class HistoricalCategorySpendingFamily
    extends Family<AsyncValue<List<MonthlySpendingBreakdown>>> {
  /// See also [historicalCategorySpending].
  const HistoricalCategorySpendingFamily();

  /// See also [historicalCategorySpending].
  HistoricalCategorySpendingProvider call({
    required String categoryId,
  }) {
    return HistoricalCategorySpendingProvider(
      categoryId: categoryId,
    );
  }

  @override
  HistoricalCategorySpendingProvider getProviderOverride(
    covariant HistoricalCategorySpendingProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'historicalCategorySpendingProvider';
}

/// See also [historicalCategorySpending].
class HistoricalCategorySpendingProvider
    extends AutoDisposeFutureProvider<List<MonthlySpendingBreakdown>> {
  /// See also [historicalCategorySpending].
  HistoricalCategorySpendingProvider({
    required String categoryId,
  }) : this._internal(
          (ref) => historicalCategorySpending(
            ref as HistoricalCategorySpendingRef,
            categoryId: categoryId,
          ),
          from: historicalCategorySpendingProvider,
          name: r'historicalCategorySpendingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$historicalCategorySpendingHash,
          dependencies: HistoricalCategorySpendingFamily._dependencies,
          allTransitiveDependencies:
              HistoricalCategorySpendingFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  HistoricalCategorySpendingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<List<MonthlySpendingBreakdown>> Function(
            HistoricalCategorySpendingRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HistoricalCategorySpendingProvider._internal(
        (ref) => create(ref as HistoricalCategorySpendingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MonthlySpendingBreakdown>>
      createElement() {
    return _HistoricalCategorySpendingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoricalCategorySpendingProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HistoricalCategorySpendingRef
    on AutoDisposeFutureProviderRef<List<MonthlySpendingBreakdown>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _HistoricalCategorySpendingProviderElement
    extends AutoDisposeFutureProviderElement<List<MonthlySpendingBreakdown>>
    with HistoricalCategorySpendingRef {
  _HistoricalCategorySpendingProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as HistoricalCategorySpendingProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
