// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boost_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$boostStateHash() => r'4595c2c328b34790a9c4e749babc0ccf6719f6de';

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

abstract class _$BoostState
    extends BuildlessAutoDisposeAsyncNotifier<BoostControllerState> {
  late final Category toCategory;

  FutureOr<BoostControllerState> build(
    Category toCategory,
  );
}

/// See also [BoostState].
@ProviderFor(BoostState)
const boostStateProvider = BoostStateFamily();

/// See also [BoostState].
class BoostStateFamily extends Family<AsyncValue<BoostControllerState>> {
  /// See also [BoostState].
  const BoostStateFamily();

  /// See also [BoostState].
  BoostStateProvider call(
    Category toCategory,
  ) {
    return BoostStateProvider(
      toCategory,
    );
  }

  @override
  BoostStateProvider getProviderOverride(
    covariant BoostStateProvider provider,
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
  String? get name => r'boostStateProvider';
}

/// See also [BoostState].
class BoostStateProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BoostState, BoostControllerState> {
  /// See also [BoostState].
  BoostStateProvider(
    Category toCategory,
  ) : this._internal(
          () => BoostState()..toCategory = toCategory,
          from: boostStateProvider,
          name: r'boostStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$boostStateHash,
          dependencies: BoostStateFamily._dependencies,
          allTransitiveDependencies:
              BoostStateFamily._allTransitiveDependencies,
          toCategory: toCategory,
        );

  BoostStateProvider._internal(
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
  FutureOr<BoostControllerState> runNotifierBuild(
    covariant BoostState notifier,
  ) {
    return notifier.build(
      toCategory,
    );
  }

  @override
  Override overrideWith(BoostState Function() create) {
    return ProviderOverride(
      origin: this,
      override: BoostStateProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BoostState, BoostControllerState>
      createElement() {
    return _BoostStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BoostStateProvider && other.toCategory == toCategory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, toCategory.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BoostStateRef
    on AutoDisposeAsyncNotifierProviderRef<BoostControllerState> {
  /// The parameter `toCategory` of this provider.
  Category get toCategory;
}

class _BoostStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BoostState,
        BoostControllerState> with BoostStateRef {
  _BoostStateProviderElement(super.provider);

  @override
  Category get toCategory => (origin as BoostStateProvider).toCategory;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
