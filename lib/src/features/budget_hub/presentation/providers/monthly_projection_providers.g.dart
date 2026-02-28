// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_projection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyCategoryProgressHash() =>
    r'9bc24616825f5582a104ad314eb88733309cfbb9';

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

/// See also [monthlyCategoryProgress].
@ProviderFor(monthlyCategoryProgress)
const monthlyCategoryProgressProvider = MonthlyCategoryProgressFamily();

/// See also [monthlyCategoryProgress].
class MonthlyCategoryProgressFamily
    extends Family<AsyncValue<List<BudgetProgress>>> {
  /// See also [monthlyCategoryProgress].
  const MonthlyCategoryProgressFamily();

  /// See also [monthlyCategoryProgress].
  MonthlyCategoryProgressProvider call(
    DateTime month,
  ) {
    return MonthlyCategoryProgressProvider(
      month,
    );
  }

  @override
  MonthlyCategoryProgressProvider getProviderOverride(
    covariant MonthlyCategoryProgressProvider provider,
  ) {
    return call(
      provider.month,
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
  String? get name => r'monthlyCategoryProgressProvider';
}

/// See also [monthlyCategoryProgress].
class MonthlyCategoryProgressProvider
    extends AutoDisposeFutureProvider<List<BudgetProgress>> {
  /// See also [monthlyCategoryProgress].
  MonthlyCategoryProgressProvider(
    DateTime month,
  ) : this._internal(
          (ref) => monthlyCategoryProgress(
            ref as MonthlyCategoryProgressRef,
            month,
          ),
          from: monthlyCategoryProgressProvider,
          name: r'monthlyCategoryProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyCategoryProgressHash,
          dependencies: MonthlyCategoryProgressFamily._dependencies,
          allTransitiveDependencies:
              MonthlyCategoryProgressFamily._allTransitiveDependencies,
          month: month,
        );

  MonthlyCategoryProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<List<BudgetProgress>> Function(MonthlyCategoryProgressRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyCategoryProgressProvider._internal(
        (ref) => create(ref as MonthlyCategoryProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BudgetProgress>> createElement() {
    return _MonthlyCategoryProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyCategoryProgressProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlyCategoryProgressRef
    on AutoDisposeFutureProviderRef<List<BudgetProgress>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyCategoryProgressProviderElement
    extends AutoDisposeFutureProviderElement<List<BudgetProgress>>
    with MonthlyCategoryProgressRef {
  _MonthlyCategoryProgressProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlyCategoryProgressProvider).month;
}

String _$globalMonthlyHistoryHash() =>
    r'686afa36d5f550fa979f4b3a09cf255403f01ed5';

/// See also [globalMonthlyHistory].
@ProviderFor(globalMonthlyHistory)
final globalMonthlyHistoryProvider =
    FutureProvider<List<MonthlySpending>>.internal(
  globalMonthlyHistory,
  name: r'globalMonthlyHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$globalMonthlyHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GlobalMonthlyHistoryRef = FutureProviderRef<List<MonthlySpending>>;
String _$monthlySummaryDetailsHash() =>
    r'1cef3188cdcc8bee97e5e9225d343a8d31e1199e';

/// See also [monthlySummaryDetails].
@ProviderFor(monthlySummaryDetails)
const monthlySummaryDetailsProvider = MonthlySummaryDetailsFamily();

/// See also [monthlySummaryDetails].
class MonthlySummaryDetailsFamily
    extends Family<AsyncValue<MonthlySummaryDetails>> {
  /// See also [monthlySummaryDetails].
  const MonthlySummaryDetailsFamily();

  /// See also [monthlySummaryDetails].
  MonthlySummaryDetailsProvider call(
    DateTime month,
  ) {
    return MonthlySummaryDetailsProvider(
      month,
    );
  }

  @override
  MonthlySummaryDetailsProvider getProviderOverride(
    covariant MonthlySummaryDetailsProvider provider,
  ) {
    return call(
      provider.month,
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
  String? get name => r'monthlySummaryDetailsProvider';
}

/// See also [monthlySummaryDetails].
class MonthlySummaryDetailsProvider
    extends AutoDisposeFutureProvider<MonthlySummaryDetails> {
  /// See also [monthlySummaryDetails].
  MonthlySummaryDetailsProvider(
    DateTime month,
  ) : this._internal(
          (ref) => monthlySummaryDetails(
            ref as MonthlySummaryDetailsRef,
            month,
          ),
          from: monthlySummaryDetailsProvider,
          name: r'monthlySummaryDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlySummaryDetailsHash,
          dependencies: MonthlySummaryDetailsFamily._dependencies,
          allTransitiveDependencies:
              MonthlySummaryDetailsFamily._allTransitiveDependencies,
          month: month,
        );

  MonthlySummaryDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<MonthlySummaryDetails> Function(MonthlySummaryDetailsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlySummaryDetailsProvider._internal(
        (ref) => create(ref as MonthlySummaryDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MonthlySummaryDetails> createElement() {
    return _MonthlySummaryDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySummaryDetailsProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlySummaryDetailsRef
    on AutoDisposeFutureProviderRef<MonthlySummaryDetails> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlySummaryDetailsProviderElement
    extends AutoDisposeFutureProviderElement<MonthlySummaryDetails>
    with MonthlySummaryDetailsRef {
  _MonthlySummaryDetailsProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlySummaryDetailsProvider).month;
}

String _$historicalCategorySpendingHash() =>
    r'2f3218f8f70162e7b77a81a40e688efd18bbecbb';

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
    r'24b8471adfb481f0469468c9154693b9c0eaf48b';

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

String _$categoryGaugeDataHash() => r'cbc6fb1b5fb133b3b06903575caed8c799043557';

/// See also [categoryGaugeData].
@ProviderFor(categoryGaugeData)
const categoryGaugeDataProvider = CategoryGaugeDataFamily();

/// See also [categoryGaugeData].
class CategoryGaugeDataFamily extends Family<CategoryGaugeData> {
  /// See also [categoryGaugeData].
  const CategoryGaugeDataFamily();

  /// See also [categoryGaugeData].
  CategoryGaugeDataProvider call({
    required Category category,
    required DateTime month,
  }) {
    return CategoryGaugeDataProvider(
      category: category,
      month: month,
    );
  }

  @override
  CategoryGaugeDataProvider getProviderOverride(
    covariant CategoryGaugeDataProvider provider,
  ) {
    return call(
      category: provider.category,
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
  String? get name => r'categoryGaugeDataProvider';
}

/// See also [categoryGaugeData].
class CategoryGaugeDataProvider extends AutoDisposeProvider<CategoryGaugeData> {
  /// See also [categoryGaugeData].
  CategoryGaugeDataProvider({
    required Category category,
    required DateTime month,
  }) : this._internal(
          (ref) => categoryGaugeData(
            ref as CategoryGaugeDataRef,
            category: category,
            month: month,
          ),
          from: categoryGaugeDataProvider,
          name: r'categoryGaugeDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryGaugeDataHash,
          dependencies: CategoryGaugeDataFamily._dependencies,
          allTransitiveDependencies:
              CategoryGaugeDataFamily._allTransitiveDependencies,
          category: category,
          month: month,
        );

  CategoryGaugeDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
    required this.month,
  }) : super.internal();

  final Category category;
  final DateTime month;

  @override
  Override overrideWith(
    CategoryGaugeData Function(CategoryGaugeDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryGaugeDataProvider._internal(
        (ref) => create(ref as CategoryGaugeDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CategoryGaugeData> createElement() {
    return _CategoryGaugeDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryGaugeDataProvider &&
        other.category == category &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryGaugeDataRef on AutoDisposeProviderRef<CategoryGaugeData> {
  /// The parameter `category` of this provider.
  Category get category;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _CategoryGaugeDataProviderElement
    extends AutoDisposeProviderElement<CategoryGaugeData>
    with CategoryGaugeDataRef {
  _CategoryGaugeDataProviderElement(super.provider);

  @override
  Category get category => (origin as CategoryGaugeDataProvider).category;
  @override
  DateTime get month => (origin as CategoryGaugeDataProvider).month;
}

String _$monthlyScreenDataHash() => r'1d7695d50e888595b85c173ba29e05c8f808f28e';

/// See also [monthlyScreenData].
@ProviderFor(monthlyScreenData)
final monthlyScreenDataProvider =
    AutoDisposeFutureProvider<MonthlyScreenData>.internal(
  monthlyScreenData,
  name: r'monthlyScreenDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyScreenDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyScreenDataRef = AutoDisposeFutureProviderRef<MonthlyScreenData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
