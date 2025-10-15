// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetSummaryDetailsHash() =>
    r'5581f987bced9c538d25ab45f40785627d4b97d0';

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

/// See also [budgetSummaryDetails].
@ProviderFor(budgetSummaryDetails)
const budgetSummaryDetailsProvider = BudgetSummaryDetailsFamily();

/// See also [budgetSummaryDetails].
class BudgetSummaryDetailsFamily
    extends Family<AsyncValue<BudgetSummaryDetails>> {
  /// See also [budgetSummaryDetails].
  const BudgetSummaryDetailsFamily();

  /// See also [budgetSummaryDetails].
  BudgetSummaryDetailsProvider call(
    DateTime month,
  ) {
    return BudgetSummaryDetailsProvider(
      month,
    );
  }

  @override
  BudgetSummaryDetailsProvider getProviderOverride(
    covariant BudgetSummaryDetailsProvider provider,
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
  String? get name => r'budgetSummaryDetailsProvider';
}

/// See also [budgetSummaryDetails].
class BudgetSummaryDetailsProvider
    extends AutoDisposeFutureProvider<BudgetSummaryDetails> {
  /// See also [budgetSummaryDetails].
  BudgetSummaryDetailsProvider(
    DateTime month,
  ) : this._internal(
          (ref) => budgetSummaryDetails(
            ref as BudgetSummaryDetailsRef,
            month,
          ),
          from: budgetSummaryDetailsProvider,
          name: r'budgetSummaryDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$budgetSummaryDetailsHash,
          dependencies: BudgetSummaryDetailsFamily._dependencies,
          allTransitiveDependencies:
              BudgetSummaryDetailsFamily._allTransitiveDependencies,
          month: month,
        );

  BudgetSummaryDetailsProvider._internal(
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
    FutureOr<BudgetSummaryDetails> Function(BudgetSummaryDetailsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetSummaryDetailsProvider._internal(
        (ref) => create(ref as BudgetSummaryDetailsRef),
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
  AutoDisposeFutureProviderElement<BudgetSummaryDetails> createElement() {
    return _BudgetSummaryDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetSummaryDetailsProvider && other.month == month;
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
mixin BudgetSummaryDetailsRef
    on AutoDisposeFutureProviderRef<BudgetSummaryDetails> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _BudgetSummaryDetailsProviderElement
    extends AutoDisposeFutureProviderElement<BudgetSummaryDetails>
    with BudgetSummaryDetailsRef {
  _BudgetSummaryDetailsProviderElement(super.provider);

  @override
  DateTime get month => (origin as BudgetSummaryDetailsProvider).month;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
