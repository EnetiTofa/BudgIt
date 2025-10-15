// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_category_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manageCategoryControllerHash() =>
    r'c5f68c50c1de660c2a6a108262e849aeaf83f1cd';

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

abstract class _$ManageCategoryController
    extends BuildlessAutoDisposeAsyncNotifier<ManageCategoryState> {
  late final String categoryId;

  FutureOr<ManageCategoryState> build(
    String categoryId,
  );
}

/// See also [ManageCategoryController].
@ProviderFor(ManageCategoryController)
const manageCategoryControllerProvider = ManageCategoryControllerFamily();

/// See also [ManageCategoryController].
class ManageCategoryControllerFamily
    extends Family<AsyncValue<ManageCategoryState>> {
  /// See also [ManageCategoryController].
  const ManageCategoryControllerFamily();

  /// See also [ManageCategoryController].
  ManageCategoryControllerProvider call(
    String categoryId,
  ) {
    return ManageCategoryControllerProvider(
      categoryId,
    );
  }

  @override
  ManageCategoryControllerProvider getProviderOverride(
    covariant ManageCategoryControllerProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'manageCategoryControllerProvider';
}

/// See also [ManageCategoryController].
class ManageCategoryControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ManageCategoryController,
        ManageCategoryState> {
  /// See also [ManageCategoryController].
  ManageCategoryControllerProvider(
    String categoryId,
  ) : this._internal(
          () => ManageCategoryController()..categoryId = categoryId,
          from: manageCategoryControllerProvider,
          name: r'manageCategoryControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$manageCategoryControllerHash,
          dependencies: ManageCategoryControllerFamily._dependencies,
          allTransitiveDependencies:
              ManageCategoryControllerFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  ManageCategoryControllerProvider._internal(
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
  FutureOr<ManageCategoryState> runNotifierBuild(
    covariant ManageCategoryController notifier,
  ) {
    return notifier.build(
      categoryId,
    );
  }

  @override
  Override overrideWith(ManageCategoryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ManageCategoryControllerProvider._internal(
        () => create()..categoryId = categoryId,
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
  AutoDisposeAsyncNotifierProviderElement<ManageCategoryController,
      ManageCategoryState> createElement() {
    return _ManageCategoryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManageCategoryControllerProvider &&
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
mixin ManageCategoryControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ManageCategoryState> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _ManageCategoryControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ManageCategoryController,
        ManageCategoryState> with ManageCategoryControllerRef {
  _ManageCategoryControllerProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as ManageCategoryControllerProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
