// lib/src/features/transactions/presentation/controllers/log_filter_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';

part 'log_filter_controller.g.dart';

// --- THE FIX IS HERE ---
// Add `keepAlive: true` to prevent the filter state from resetting during navigation.
@Riverpod(keepAlive: true)
// --- END OF FIX ---
class LogFilter extends _$LogFilter {
  @override
  LogFilterState build() {
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
  
  void setSelectedCategoryIds(Set<String> ids) {
    state = state.copyWith(selectedCategoryIds: ids);
  }
}