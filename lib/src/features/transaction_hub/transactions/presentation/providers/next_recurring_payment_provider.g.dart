// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_recurring_payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nextRecurringPaymentHash() =>
    r'7f400a5e1e71cb62365d9dd6536ea770d6bb4ca7';

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

/// See also [nextRecurringPayment].
@ProviderFor(nextRecurringPayment)
const nextRecurringPaymentProvider = NextRecurringPaymentFamily();

/// See also [nextRecurringPayment].
class NextRecurringPaymentFamily
    extends Family<AsyncValue<PaymentOccurrence?>> {
  /// See also [nextRecurringPayment].
  const NextRecurringPaymentFamily();

  /// See also [nextRecurringPayment].
  NextRecurringPaymentProvider call({
    required String categoryId,
  }) {
    return NextRecurringPaymentProvider(
      categoryId: categoryId,
    );
  }

  @override
  NextRecurringPaymentProvider getProviderOverride(
    covariant NextRecurringPaymentProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
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
  String? get name => r'nextRecurringPaymentProvider';
}

/// See also [nextRecurringPayment].
class NextRecurringPaymentProvider
    extends AutoDisposeFutureProvider<PaymentOccurrence?> {
  /// See also [nextRecurringPayment].
  NextRecurringPaymentProvider({
    required String categoryId,
  }) : this._internal(
          (ref) => nextRecurringPayment(
            ref as NextRecurringPaymentRef,
            categoryId: categoryId,
          ),
          from: nextRecurringPaymentProvider,
          name: r'nextRecurringPaymentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nextRecurringPaymentHash,
          dependencies: NextRecurringPaymentFamily._dependencies,
          allTransitiveDependencies:
              NextRecurringPaymentFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  NextRecurringPaymentProvider._internal(
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
  Override overrideWith(
    FutureOr<PaymentOccurrence?> Function(NextRecurringPaymentRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NextRecurringPaymentProvider._internal(
        (ref) => create(ref as NextRecurringPaymentRef),
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
  AutoDisposeFutureProviderElement<PaymentOccurrence?> createElement() {
    return _NextRecurringPaymentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NextRecurringPaymentProvider &&
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
mixin NextRecurringPaymentRef
    on AutoDisposeFutureProviderRef<PaymentOccurrence?> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _NextRecurringPaymentProviderElement
    extends AutoDisposeFutureProviderElement<PaymentOccurrence?>
    with NextRecurringPaymentRef {
  _NextRecurringPaymentProviderElement(super.provider);

  @override
  String get categoryId => (origin as NextRecurringPaymentProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
