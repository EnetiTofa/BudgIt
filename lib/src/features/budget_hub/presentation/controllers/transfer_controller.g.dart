// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transferControllerHash() =>
    r'b7c600973e9e7e32247ec13ca1ab1b34a0d86338';

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

abstract class _$TransferController
    extends BuildlessAutoDisposeAsyncNotifier<TransferControllerState> {
  late final Category toCategory;

  FutureOr<TransferControllerState> build(
    Category toCategory,
  );
}

/// See also [TransferController].
@ProviderFor(TransferController)
const transferControllerProvider = TransferControllerFamily();

/// See also [TransferController].
class TransferControllerFamily
    extends Family<AsyncValue<TransferControllerState>> {
  /// See also [TransferController].
  const TransferControllerFamily();

  /// See also [TransferController].
  TransferControllerProvider call(
    Category toCategory,
  ) {
    return TransferControllerProvider(
      toCategory,
    );
  }

  @override
  TransferControllerProvider getProviderOverride(
    covariant TransferControllerProvider provider,
  ) {
    return call(
      provider.toCategory,
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
  String? get name => r'transferControllerProvider';
}

/// See also [TransferController].
class TransferControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TransferController, TransferControllerState> {
  /// See also [TransferController].
  TransferControllerProvider(
    Category toCategory,
  ) : this._internal(
          () => TransferController()..toCategory = toCategory,
          from: transferControllerProvider,
          name: r'transferControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transferControllerHash,
          dependencies: TransferControllerFamily._dependencies,
          allTransitiveDependencies:
              TransferControllerFamily._allTransitiveDependencies,
          toCategory: toCategory,
        );

  TransferControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.toCategory,
  }) : super.internal();

  final Category toCategory;

  @override
  FutureOr<TransferControllerState> runNotifierBuild(
    covariant TransferController notifier,
  ) {
    return notifier.build(
      toCategory,
    );
  }

  @override
  Override overrideWith(TransferController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TransferControllerProvider._internal(
        () => create()..toCategory = toCategory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        toCategory: toCategory,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TransferController,
      TransferControllerState> createElement() {
    return _TransferControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransferControllerProvider &&
        other.toCategory == toCategory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, toCategory.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransferControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TransferControllerState> {
  /// The parameter `toCategory` of this provider.
  Category get toCategory;
}

class _TransferControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TransferController,
        TransferControllerState> with TransferControllerRef {
  _TransferControllerProviderElement(super.provider);

  @override
  Category get toCategory => (origin as TransferControllerProvider).toCategory;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
