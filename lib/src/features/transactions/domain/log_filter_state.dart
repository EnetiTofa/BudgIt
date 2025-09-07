import 'package:equatable/equatable.dart';

enum SortBy { date, category, store }

class LogFilterState extends Equatable {
  const LogFilterState({
    this.searchQuery = '',
    this.sortBy = SortBy.date,
    this.selectedCategoryIds = const {},
  });

  final String searchQuery;
  final SortBy sortBy;
  final Set<String> selectedCategoryIds;

  LogFilterState copyWith({
    String? searchQuery,
    SortBy? sortBy,
    Set<String>? selectedCategoryIds,
  }) {
    return LogFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }

  @override
  List<Object?> get props => [searchQuery, sortBy, selectedCategoryIds];
}