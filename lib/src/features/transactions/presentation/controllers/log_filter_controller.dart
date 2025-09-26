import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';

part 'log_filter_controller.g.dart';

@riverpod
class LogFilter extends _$LogFilter {
  @override
  LogFilterState build() {
    // Return the default state
    return const LogFilterState();
  }

  void setTransactionType(TransactionTypeFilter type) {
    state = state.copyWith(transactionTypeFilter: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void toggleCategoryFilter(String categoryId) {
    final newSet = Set<String>.from(state.selectedCategoryIds);
    if (newSet.contains(categoryId)) {
      newSet.remove(categoryId);
    } else {
      newSet.add(categoryId);
    }
    state = state.copyWith(selectedCategoryIds: newSet);
  }
}