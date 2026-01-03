// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_category_spending_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historicalCategorySpendingHash() =>
    r'963930348717b71c1ba16b8da8e5021cb9fb9c50';

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
    extends Family<List<MonthlySpendingBreakdown>> {
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
    extends AutoDisposeProvider<List<MonthlySpendingBreakdown>> {
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
    List<MonthlySpendingBreakdown> Function(
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
  AutoDisposeProviderElement<List<MonthlySpendingBreakdown>> createElement() {
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

mixin HistoricalCategorySpendingRef
    on AutoDisposeProviderRef<List<MonthlySpendingBreakdown>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _HistoricalCategorySpendingProviderElement
    extends AutoDisposeProviderElement<List<MonthlySpendingBreakdown>>
    with HistoricalCategorySpendingRef {
  _HistoricalCategorySpendingProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as HistoricalCategorySpendingProvider).categoryId;
}

String _$categoryMonthlyBreakdownHash() =>
    r'ca478eb0e9fbef57f035fc4d0c62b8673c69d659';

/// See also [categoryMonthlyBreakdown].
@ProviderFor(categoryMonthlyBreakdown)
const categoryMonthlyBreakdownProvider = CategoryMonthlyBreakdownFamily();

/// See also [categoryMonthlyBreakdown].
class CategoryMonthlyBreakdownFamily extends Family<MonthlySpendingBreakdown> {
  /// See also [categoryMonthlyBreakdown].
  const CategoryMonthlyBreakdownFamily();

  /// See also [categoryMonthlyBreakdown].
  CategoryMonthlyBreakdownProvider call({
    required String categoryId,
    required DateTime month,
  }) {
    return CategoryMonthlyBreakdownProvider(
      categoryId: categoryId,
      month: month,
    );
  }

  @override
  CategoryMonthlyBreakdownProvider getProviderOverride(
    covariant CategoryMonthlyBreakdownProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
      month: provider.month,
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
  String? get name => r'categoryMonthlyBreakdownProvider';
}

/// See also [categoryMonthlyBreakdown].
class CategoryMonthlyBreakdownProvider
    extends AutoDisposeProvider<MonthlySpendingBreakdown> {
  /// See also [categoryMonthlyBreakdown].
  CategoryMonthlyBreakdownProvider({
    required String categoryId,
    required DateTime month,
  }) : this._internal(
          (ref) => categoryMonthlyBreakdown(
            ref as CategoryMonthlyBreakdownRef,
            categoryId: categoryId,
            month: month,
          ),
          from: categoryMonthlyBreakdownProvider,
          name: r'categoryMonthlyBreakdownProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryMonthlyBreakdownHash,
          dependencies: CategoryMonthlyBreakdownFamily._dependencies,
          allTransitiveDependencies:
              CategoryMonthlyBreakdownFamily._allTransitiveDependencies,
          categoryId: categoryId,
          month: month,
        );

  CategoryMonthlyBreakdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.month,
  }) : super.internal();

  final String categoryId;
  final DateTime month;

  @override
  Override overrideWith(
    MonthlySpendingBreakdown Function(CategoryMonthlyBreakdownRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryMonthlyBreakdownProvider._internal(
        (ref) => create(ref as CategoryMonthlyBreakdownRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MonthlySpendingBreakdown> createElement() {
    return _CategoryMonthlyBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryMonthlyBreakdownProvider &&
        other.categoryId == categoryId &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryMonthlyBreakdownRef
    on AutoDisposeProviderRef<MonthlySpendingBreakdown> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _CategoryMonthlyBreakdownProviderElement
    extends AutoDisposeProviderElement<MonthlySpendingBreakdown>
    with CategoryMonthlyBreakdownRef {
  _CategoryMonthlyBreakdownProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as CategoryMonthlyBreakdownProvider).categoryId;
  @override
  DateTime get month => (origin as CategoryMonthlyBreakdownProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
