// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_filter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogFilterState {
// The @Default() annotation replaces constructor default values.
  TransactionTypeFilter get transactionTypeFilter =>
      throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  SortBy get sortBy => throw _privateConstructorUsedError;
  Set<String> get selectedCategoryIds => throw _privateConstructorUsedError;

  /// Create a copy of LogFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogFilterStateCopyWith<LogFilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogFilterStateCopyWith<$Res> {
  factory $LogFilterStateCopyWith(
          LogFilterState value, $Res Function(LogFilterState) then) =
      _$LogFilterStateCopyWithImpl<$Res, LogFilterState>;
  @useResult
  $Res call(
      {TransactionTypeFilter transactionTypeFilter,
      String searchQuery,
      SortBy sortBy,
      Set<String> selectedCategoryIds});
}

/// @nodoc
class _$LogFilterStateCopyWithImpl<$Res, $Val extends LogFilterState>
    implements $LogFilterStateCopyWith<$Res> {
  _$LogFilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionTypeFilter = null,
    Object? searchQuery = null,
    Object? sortBy = null,
    Object? selectedCategoryIds = null,
  }) {
    return _then(_value.copyWith(
      transactionTypeFilter: null == transactionTypeFilter
          ? _value.transactionTypeFilter
          : transactionTypeFilter // ignore: cast_nullable_to_non_nullable
              as TransactionTypeFilter,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      selectedCategoryIds: null == selectedCategoryIds
          ? _value.selectedCategoryIds
          : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogFilterStateImplCopyWith<$Res>
    implements $LogFilterStateCopyWith<$Res> {
  factory _$$LogFilterStateImplCopyWith(_$LogFilterStateImpl value,
          $Res Function(_$LogFilterStateImpl) then) =
      __$$LogFilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TransactionTypeFilter transactionTypeFilter,
      String searchQuery,
      SortBy sortBy,
      Set<String> selectedCategoryIds});
}

/// @nodoc
class __$$LogFilterStateImplCopyWithImpl<$Res>
    extends _$LogFilterStateCopyWithImpl<$Res, _$LogFilterStateImpl>
    implements _$$LogFilterStateImplCopyWith<$Res> {
  __$$LogFilterStateImplCopyWithImpl(
      _$LogFilterStateImpl _value, $Res Function(_$LogFilterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionTypeFilter = null,
    Object? searchQuery = null,
    Object? sortBy = null,
    Object? selectedCategoryIds = null,
  }) {
    return _then(_$LogFilterStateImpl(
      transactionTypeFilter: null == transactionTypeFilter
          ? _value.transactionTypeFilter
          : transactionTypeFilter // ignore: cast_nullable_to_non_nullable
              as TransactionTypeFilter,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      selectedCategoryIds: null == selectedCategoryIds
          ? _value._selectedCategoryIds
          : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$LogFilterStateImpl implements _LogFilterState {
  const _$LogFilterStateImpl(
      {this.transactionTypeFilter = TransactionTypeFilter.all,
      this.searchQuery = '',
      this.sortBy = SortBy.date,
      final Set<String> selectedCategoryIds = const {}})
      : _selectedCategoryIds = selectedCategoryIds;

// The @Default() annotation replaces constructor default values.
  @override
  @JsonKey()
  final TransactionTypeFilter transactionTypeFilter;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final SortBy sortBy;
  final Set<String> _selectedCategoryIds;
  @override
  @JsonKey()
  Set<String> get selectedCategoryIds {
    if (_selectedCategoryIds is EqualUnmodifiableSetView)
      return _selectedCategoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedCategoryIds);
  }

  @override
  String toString() {
    return 'LogFilterState(transactionTypeFilter: $transactionTypeFilter, searchQuery: $searchQuery, sortBy: $sortBy, selectedCategoryIds: $selectedCategoryIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogFilterStateImpl &&
            (identical(other.transactionTypeFilter, transactionTypeFilter) ||
                other.transactionTypeFilter == transactionTypeFilter) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            const DeepCollectionEquality()
                .equals(other._selectedCategoryIds, _selectedCategoryIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      transactionTypeFilter,
      searchQuery,
      sortBy,
      const DeepCollectionEquality().hash(_selectedCategoryIds));

  /// Create a copy of LogFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogFilterStateImplCopyWith<_$LogFilterStateImpl> get copyWith =>
      __$$LogFilterStateImplCopyWithImpl<_$LogFilterStateImpl>(
          this, _$identity);
}

abstract class _LogFilterState implements LogFilterState {
  const factory _LogFilterState(
      {final TransactionTypeFilter transactionTypeFilter,
      final String searchQuery,
      final SortBy sortBy,
      final Set<String> selectedCategoryIds}) = _$LogFilterStateImpl;

// The @Default() annotation replaces constructor default values.
  @override
  TransactionTypeFilter get transactionTypeFilter;
  @override
  String get searchQuery;
  @override
  SortBy get sortBy;
  @override
  Set<String> get selectedCategoryIds;

  /// Create a copy of LogFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogFilterStateImplCopyWith<_$LogFilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
