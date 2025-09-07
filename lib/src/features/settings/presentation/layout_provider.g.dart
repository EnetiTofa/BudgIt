// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$screenLayoutNotifierHash() =>
    r'bf901fb42b9ad8d2e18f5fa3bc511c92c631e5bf';

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

abstract class _$ScreenLayoutNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ScreenLayout> {
  late final String screenId;
  late final List<String> defaultOrder;

  FutureOr<ScreenLayout> build(
    String screenId, {
    required List<String> defaultOrder,
  });
}

/// See also [ScreenLayoutNotifier].
@ProviderFor(ScreenLayoutNotifier)
const screenLayoutNotifierProvider = ScreenLayoutNotifierFamily();

/// See also [ScreenLayoutNotifier].
class ScreenLayoutNotifierFamily extends Family<AsyncValue<ScreenLayout>> {
  /// See also [ScreenLayoutNotifier].
  const ScreenLayoutNotifierFamily();

  /// See also [ScreenLayoutNotifier].
  ScreenLayoutNotifierProvider call(
    String screenId, {
    required List<String> defaultOrder,
  }) {
    return ScreenLayoutNotifierProvider(
      screenId,
      defaultOrder: defaultOrder,
    );
  }

  @override
  ScreenLayoutNotifierProvider getProviderOverride(
    covariant ScreenLayoutNotifierProvider provider,
  ) {
    return call(
      provider.screenId,
      defaultOrder: provider.defaultOrder,
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
  String? get name => r'screenLayoutNotifierProvider';
}

/// See also [ScreenLayoutNotifier].
class ScreenLayoutNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ScreenLayoutNotifier, ScreenLayout> {
  /// See also [ScreenLayoutNotifier].
  ScreenLayoutNotifierProvider(
    String screenId, {
    required List<String> defaultOrder,
  }) : this._internal(
          () => ScreenLayoutNotifier()
            ..screenId = screenId
            ..defaultOrder = defaultOrder,
          from: screenLayoutNotifierProvider,
          name: r'screenLayoutNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$screenLayoutNotifierHash,
          dependencies: ScreenLayoutNotifierFamily._dependencies,
          allTransitiveDependencies:
              ScreenLayoutNotifierFamily._allTransitiveDependencies,
          screenId: screenId,
          defaultOrder: defaultOrder,
        );

  ScreenLayoutNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.screenId,
    required this.defaultOrder,
  }) : super.internal();

  final String screenId;
  final List<String> defaultOrder;

  @override
  FutureOr<ScreenLayout> runNotifierBuild(
    covariant ScreenLayoutNotifier notifier,
  ) {
    return notifier.build(
      screenId,
      defaultOrder: defaultOrder,
    );
  }

  @override
  Override overrideWith(ScreenLayoutNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ScreenLayoutNotifierProvider._internal(
        () => create()
          ..screenId = screenId
          ..defaultOrder = defaultOrder,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        screenId: screenId,
        defaultOrder: defaultOrder,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ScreenLayoutNotifier, ScreenLayout>
      createElement() {
    return _ScreenLayoutNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenLayoutNotifierProvider &&
        other.screenId == screenId &&
        other.defaultOrder == defaultOrder;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, screenId.hashCode);
    hash = _SystemHash.combine(hash, defaultOrder.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScreenLayoutNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<ScreenLayout> {
  /// The parameter `screenId` of this provider.
  String get screenId;

  /// The parameter `defaultOrder` of this provider.
  List<String> get defaultOrder;
}

class _ScreenLayoutNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ScreenLayoutNotifier,
        ScreenLayout> with ScreenLayoutNotifierRef {
  _ScreenLayoutNotifierProviderElement(super.provider);

  @override
  String get screenId => (origin as ScreenLayoutNotifierProvider).screenId;
  @override
  List<String> get defaultOrder =>
      (origin as ScreenLayoutNotifierProvider).defaultOrder;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
