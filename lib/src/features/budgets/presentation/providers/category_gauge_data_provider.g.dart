// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_gauge_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryGaugeDataHash() => r'94f2206170a5c5e0a470a3c01a9bb71ac40ee458';

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

/// See also [categoryGaugeData].
@ProviderFor(categoryGaugeData)
const categoryGaugeDataProvider = CategoryGaugeDataFamily();

/// See also [categoryGaugeData].
class CategoryGaugeDataFamily extends Family<AsyncValue<CategoryGaugeData>> {
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
class CategoryGaugeDataProvider
    extends AutoDisposeFutureProvider<CategoryGaugeData> {
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
    FutureOr<CategoryGaugeData> Function(CategoryGaugeDataRef provider) create,
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
  AutoDisposeFutureProviderElement<CategoryGaugeData> createElement() {
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryGaugeDataRef on AutoDisposeFutureProviderRef<CategoryGaugeData> {
  /// The parameter `category` of this provider.
  Category get category;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _CategoryGaugeDataProviderElement
    extends AutoDisposeFutureProviderElement<CategoryGaugeData>
    with CategoryGaugeDataRef {
  _CategoryGaugeDataProviderElement(super.provider);

  @override
  Category get category => (origin as CategoryGaugeDataProvider).category;
  @override
  DateTime get month => (origin as CategoryGaugeDataProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
