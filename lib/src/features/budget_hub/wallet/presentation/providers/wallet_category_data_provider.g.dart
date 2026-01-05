// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_category_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletCategoryDataHash() =>
    r'9cb6f5031f861488176580ccfc8d4f80f6ff2770';

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

/// See also [walletCategoryData].
@ProviderFor(walletCategoryData)
const walletCategoryDataProvider = WalletCategoryDataFamily();

/// See also [walletCategoryData].
class WalletCategoryDataFamily
    extends Family<AsyncValue<List<WalletCategoryData>>> {
  /// See also [walletCategoryData].
  const WalletCategoryDataFamily();

  /// See also [walletCategoryData].
  WalletCategoryDataProvider call({
    required DateTime selectedDate,
  }) {
    return WalletCategoryDataProvider(
      selectedDate: selectedDate,
    );
  }

  @override
  WalletCategoryDataProvider getProviderOverride(
    covariant WalletCategoryDataProvider provider,
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
  String? get name => r'walletCategoryDataProvider';
}

/// See also [walletCategoryData].
class WalletCategoryDataProvider
    extends FutureProvider<List<WalletCategoryData>> {
  /// See also [walletCategoryData].
  WalletCategoryDataProvider({
    required DateTime selectedDate,
  }) : this._internal(
          (ref) => walletCategoryData(
            ref as WalletCategoryDataRef,
            selectedDate: selectedDate,
          ),
          from: walletCategoryDataProvider,
          name: r'walletCategoryDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$walletCategoryDataHash,
          dependencies: WalletCategoryDataFamily._dependencies,
          allTransitiveDependencies:
              WalletCategoryDataFamily._allTransitiveDependencies,
          selectedDate: selectedDate,
        );

  WalletCategoryDataProvider._internal(
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
    FutureOr<List<WalletCategoryData>> Function(WalletCategoryDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletCategoryDataProvider._internal(
        (ref) => create(ref as WalletCategoryDataRef),
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
  FutureProviderElement<List<WalletCategoryData>> createElement() {
    return _WalletCategoryDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletCategoryDataProvider &&
        other.selectedDate == selectedDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WalletCategoryDataRef on FutureProviderRef<List<WalletCategoryData>> {
  /// The parameter `selectedDate` of this provider.
  DateTime get selectedDate;
}

class _WalletCategoryDataProviderElement
    extends FutureProviderElement<List<WalletCategoryData>>
    with WalletCategoryDataRef {
  _WalletCategoryDataProviderElement(super.provider);

  @override
  DateTime get selectedDate =>
      (origin as WalletCategoryDataProvider).selectedDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
