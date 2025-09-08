// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetProgressHash() => r'c2066b11aa6c7fb178c21b63858684b2cb75b866';

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

/// See also [budgetProgress].
@ProviderFor(budgetProgress)
const budgetProgressProvider = BudgetProgressFamily();

/// See also [budgetProgress].
class BudgetProgressFamily extends Family<AsyncValue<List<BudgetProgress>>> {
  /// See also [budgetProgress].
  const BudgetProgressFamily();

  /// See also [budgetProgress].
  BudgetProgressProvider call(
    BudgetView budgetView,
  ) {
    return BudgetProgressProvider(
      budgetView,
    );
  }

  @override
  BudgetProgressProvider getProviderOverride(
    covariant BudgetProgressProvider provider,
  ) {
    return call(
      provider.budgetView,
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
  String? get name => r'budgetProgressProvider';
}

/// See also [budgetProgress].
class BudgetProgressProvider
    extends AutoDisposeFutureProvider<List<BudgetProgress>> {
  /// See also [budgetProgress].
  BudgetProgressProvider(
    BudgetView budgetView,
  ) : this._internal(
          (ref) => budgetProgress(
            ref as BudgetProgressRef,
            budgetView,
          ),
          from: budgetProgressProvider,
          name: r'budgetProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$budgetProgressHash,
          dependencies: BudgetProgressFamily._dependencies,
          allTransitiveDependencies:
              BudgetProgressFamily._allTransitiveDependencies,
          budgetView: budgetView,
        );

  BudgetProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.budgetView,
  }) : super.internal();

  final BudgetView budgetView;

  @override
  Override overrideWith(
    FutureOr<List<BudgetProgress>> Function(BudgetProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetProgressProvider._internal(
        (ref) => create(ref as BudgetProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        budgetView: budgetView,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BudgetProgress>> createElement() {
    return _BudgetProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetProgressProvider && other.budgetView == budgetView;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, budgetView.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BudgetProgressRef on AutoDisposeFutureProviderRef<List<BudgetProgress>> {
  /// The parameter `budgetView` of this provider.
  BudgetView get budgetView;
}

class _BudgetProgressProviderElement
    extends AutoDisposeFutureProviderElement<List<BudgetProgress>>
    with BudgetProgressRef {
  _BudgetProgressProviderElement(super.provider);

  @override
  BudgetView get budgetView => (origin as BudgetProgressProvider).budgetView;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
