// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetProgressHash() => r'ef0930eb3edb94ef45f7a3907ad2ce17d2e18498';

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
    DateTime month,
  ) {
    return BudgetProgressProvider(
      month,
    );
  }

  @override
  BudgetProgressProvider getProviderOverride(
    covariant BudgetProgressProvider provider,
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
  String? get name => r'budgetProgressProvider';
}

/// See also [budgetProgress].
class BudgetProgressProvider
    extends AutoDisposeFutureProvider<List<BudgetProgress>> {
  /// See also [budgetProgress].
  BudgetProgressProvider(
    DateTime month,
  ) : this._internal(
          (ref) => budgetProgress(
            ref as BudgetProgressRef,
            month,
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
          month: month,
        );

  BudgetProgressProvider._internal(
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
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BudgetProgress>> createElement() {
    return _BudgetProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetProgressProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BudgetProgressRef on AutoDisposeFutureProviderRef<List<BudgetProgress>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _BudgetProgressProviderElement
    extends AutoDisposeFutureProviderElement<List<BudgetProgress>>
    with BudgetProgressRef {
  _BudgetProgressProviderElement(super.provider);

  @override
  DateTime get month => (origin as BudgetProgressProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
