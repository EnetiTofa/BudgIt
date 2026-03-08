import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_filter_state.freezed.dart';

enum TransactionTypeFilter { all, payment, income }

// --- ADDED: amount ---
enum SortBy { date, category, store, amount }

@freezed
class LogFilterState with _$LogFilterState {
  const factory LogFilterState({
    @Default(TransactionTypeFilter.all)
    TransactionTypeFilter transactionTypeFilter,
    @Default('') String searchQuery,
    @Default(SortBy.date) SortBy sortBy,
    @Default({}) Set<String> selectedCategoryIds,
    DateTime? startDate,
    DateTime? endDate,
  }) = _LogFilterState;
}
