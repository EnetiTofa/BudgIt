// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_projection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weeklyCategoryDataHash() =>
    r'b5454b66c4cc9bc14b082c7ea60f52e8f9836ce8';

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

/// See also [weeklyCategoryData].
@ProviderFor(weeklyCategoryData)
const weeklyCategoryDataProvider = WeeklyCategoryDataFamily();

/// See also [weeklyCategoryData].
class WeeklyCategoryDataFamily
    extends Family<AsyncValue<List<WeeklyCategoryData>>> {
  /// See also [weeklyCategoryData].
  const WeeklyCategoryDataFamily();

  /// See also [weeklyCategoryData].
  WeeklyCategoryDataProvider call({
    required DateTime selectedDate,
  }) {
    return WeeklyCategoryDataProvider(
      selectedDate: selectedDate,
    );
  }

  @override
  WeeklyCategoryDataProvider getProviderOverride(
    covariant WeeklyCategoryDataProvider provider,
  ) {
    return call(
      selectedDate: provider.selectedDate,
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
  String? get name => r'weeklyCategoryDataProvider';
}

/// See also [weeklyCategoryData].
class WeeklyCategoryDataProvider
    extends FutureProvider<List<WeeklyCategoryData>> {
  /// See also [weeklyCategoryData].
  WeeklyCategoryDataProvider({
    required DateTime selectedDate,
  }) : this._internal(
          (ref) => weeklyCategoryData(
            ref as WeeklyCategoryDataRef,
            selectedDate: selectedDate,
          ),
          from: weeklyCategoryDataProvider,
          name: r'weeklyCategoryDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weeklyCategoryDataHash,
          dependencies: WeeklyCategoryDataFamily._dependencies,
          allTransitiveDependencies:
              WeeklyCategoryDataFamily._allTransitiveDependencies,
          selectedDate: selectedDate,
        );

  WeeklyCategoryDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedDate,
  }) : super.internal();

  final DateTime selectedDate;

  @override
  Override overrideWith(
    FutureOr<List<WeeklyCategoryData>> Function(WeeklyCategoryDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyCategoryDataProvider._internal(
        (ref) => create(ref as WeeklyCategoryDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedDate: selectedDate,
      ),
    );
  }

  @override
  FutureProviderElement<List<WeeklyCategoryData>> createElement() {
    return _WeeklyCategoryDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyCategoryDataProvider &&
        other.selectedDate == selectedDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WeeklyCategoryDataRef on FutureProviderRef<List<WeeklyCategoryData>> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;
}

class _WeeklyCategoryDataProviderElement
    extends FutureProviderElement<List<WeeklyCategoryData>>
    with WeeklyCategoryDataRef {
  _WeeklyCategoryDataProviderElement(super.provider);

  @override
  DateTime get selectedDate =>
      (origin as WeeklyCategoryDataProvider).selectedDate;
}

String _$weeklyAggregateHash() => r'39943ad3a774b34646946aa4383a4757801c68b8';

/// See also [weeklyAggregate].
@ProviderFor(weeklyAggregate)
final weeklyAggregateProvider =
    AutoDisposeFutureProvider<WeeklyAggregateData>.internal(
  weeklyAggregate,
  name: r'weeklyAggregateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyAggregateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeeklyAggregateRef = AutoDisposeFutureProviderRef<WeeklyAggregateData>;
String _$weeklyChartDataHash() => r'a21143743c21604598dce0d8eb16c56a28275f51';

/// See also [weeklyChartData].
@ProviderFor(weeklyChartData)
const weeklyChartDataProvider = WeeklyChartDataFamily();

/// See also [weeklyChartData].
class WeeklyChartDataFamily extends Family<AsyncValue<WeeklyChartData>> {
  /// See also [weeklyChartData].
  const WeeklyChartDataFamily();

  /// See also [weeklyChartData].
  WeeklyChartDataProvider call({
    required DateTime selectedDate,
  }) {
    return WeeklyChartDataProvider(
      selectedDate: selectedDate,
    );
  }

  @override
  WeeklyChartDataProvider getProviderOverride(
    covariant WeeklyChartDataProvider provider,
  ) {
    return call(
      selectedDate: provider.selectedDate,
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
  String? get name => r'weeklyChartDataProvider';
}

/// See also [weeklyChartData].
class WeeklyChartDataProvider
    extends AutoDisposeFutureProvider<WeeklyChartData> {
  /// See also [weeklyChartData].
  WeeklyChartDataProvider({
    required DateTime selectedDate,
  }) : this._internal(
          (ref) => weeklyChartData(
            ref as WeeklyChartDataRef,
            selectedDate: selectedDate,
          ),
          from: weeklyChartDataProvider,
          name: r'weeklyChartDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weeklyChartDataHash,
          dependencies: WeeklyChartDataFamily._dependencies,
          allTransitiveDependencies:
              WeeklyChartDataFamily._allTransitiveDependencies,
          selectedDate: selectedDate,
        );

  WeeklyChartDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedDate,
  }) : super.internal();

  final DateTime selectedDate;

  @override
  Override overrideWith(
    FutureOr<WeeklyChartData> Function(WeeklyChartDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyChartDataProvider._internal(
        (ref) => create(ref as WeeklyChartDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedDate: selectedDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WeeklyChartData> createElement() {
    return _WeeklyChartDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyChartDataProvider &&
        other.selectedDate == selectedDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WeeklyChartDataRef on AutoDisposeFutureProviderRef<WeeklyChartData> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;
}

class _WeeklyChartDataProviderElement
    extends AutoDisposeFutureProviderElement<WeeklyChartData>
    with WeeklyChartDataRef {
  _WeeklyChartDataProviderElement(super.provider);

  @override
  DateTime get selectedDate => (origin as WeeklyChartDataProvider).selectedDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
