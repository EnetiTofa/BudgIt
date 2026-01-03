// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_bar_chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletBarChartDataHash() =>
    r'9ffcc964ad547fc0da3f8d093c75bdea0356076c';

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

/// See also [walletBarChartData].
@ProviderFor(walletBarChartData)
const walletBarChartDataProvider = WalletBarChartDataFamily();

/// See also [walletBarChartData].
class WalletBarChartDataFamily extends Family<AsyncValue<WalletBarChartData>> {
  /// See also [walletBarChartData].
  const WalletBarChartDataFamily();

  /// See also [walletBarChartData].
  WalletBarChartDataProvider call({
    required DateTime selectedDate,
  }) {
    return WalletBarChartDataProvider(
      selectedDate: selectedDate,
    );
  }

  @override
  WalletBarChartDataProvider getProviderOverride(
    covariant WalletBarChartDataProvider provider,
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
  String? get name => r'walletBarChartDataProvider';
}

/// See also [walletBarChartData].
class WalletBarChartDataProvider
    extends AutoDisposeFutureProvider<WalletBarChartData> {
  /// See also [walletBarChartData].
  WalletBarChartDataProvider({
    required DateTime selectedDate,
  }) : this._internal(
          (ref) => walletBarChartData(
            ref as WalletBarChartDataRef,
            selectedDate: selectedDate,
          ),
          from: walletBarChartDataProvider,
          name: r'walletBarChartDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$walletBarChartDataHash,
          dependencies: WalletBarChartDataFamily._dependencies,
          allTransitiveDependencies:
              WalletBarChartDataFamily._allTransitiveDependencies,
          selectedDate: selectedDate,
        );

  WalletBarChartDataProvider._internal(
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
    FutureOr<WalletBarChartData> Function(WalletBarChartDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletBarChartDataProvider._internal(
        (ref) => create(ref as WalletBarChartDataRef),
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
  AutoDisposeFutureProviderElement<WalletBarChartData> createElement() {
    return _WalletBarChartDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletBarChartDataProvider &&
        other.selectedDate == selectedDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WalletBarChartDataRef
    on AutoDisposeFutureProviderRef<WalletBarChartData> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;
}

class _WalletBarChartDataProviderElement
    extends AutoDisposeFutureProviderElement<WalletBarChartData>
    with WalletBarChartDataRef {
  _WalletBarChartDataProviderElement(super.provider);

  @override
  DateTime get selectedDate =>
      (origin as WalletBarChartDataProvider).selectedDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
