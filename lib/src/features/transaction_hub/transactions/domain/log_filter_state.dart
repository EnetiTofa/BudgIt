import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_filter_state.freezed.dart';

// An enum to represent the type of transaction we want to show.
enum TransactionTypeFilter { all, payment, income }

// An enum for the sorting options.
enum SortBy { date, category, store }

@freezed
class LogFilterState with _$LogFilterState {
  const factory LogFilterState({
    // The @Default() annotation replaces constructor default values.
    @Default(TransactionTypeFilter.all) TransactionTypeFilter transactionTypeFilter,
    @Default('') String searchQuery,
    @Default(SortBy.date) SortBy sortBy,
    @Default({}) Set<String> selectedCategoryIds,
  }) = _LogFilterState;
}