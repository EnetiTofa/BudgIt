import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
// FIX 1: Point to the newly consolidated provider file
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'transfer_controller.g.dart';

class TransferControllerState extends Equatable {
  final Map<String, double> initialTransfers; // What is in the DB
  final Map<String, double> currentTransfers; // What is being edited

  const TransferControllerState({
    required this.initialTransfers,
    required this.currentTransfers,
  });

  @override
  List<Object?> get props => [initialTransfers, currentTransfers];

  TransferControllerState copyWith({
    Map<String, double>? initialTransfers,
    Map<String, double>? currentTransfers,
  }) {
    return TransferControllerState(
      initialTransfers: initialTransfers ?? this.initialTransfers,
      currentTransfers: currentTransfers ?? this.currentTransfers,
    );
  }
}

@riverpod
class TransferController extends _$TransferController {
  @override
  FutureOr<TransferControllerState> build(Category toCategory) async {
    final repository = ref.watch(transactionRepositoryProvider);
    final clock = ref.watch(clockNotifierProvider);

    // Fetch existing transfers from DB
    final transfers = await repository.getBudgetTransfersForWeek(clock.now());

    // Map them: FromCategoryId -> Amount (Filtering for this specific target category)
    final Map<String, double> map = {};
    for (var transfer in transfers.where(
      (t) => t.toCategoryId == toCategory.id,
    )) {
      map[transfer.fromCategoryId] = transfer.amount;
    }

    return TransferControllerState(
      initialTransfers: map,
      currentTransfers: map,
    );
  }

  void updateAmount(String fromCategoryId, double amount) {
    if (state.hasError || state.isLoading || state.value == null) return;

    final newCurrent = Map<String, double>.from(state.value!.currentTransfers);
    if (amount > 0) {
      newCurrent[fromCategoryId] = amount;
    } else {
      newCurrent.remove(fromCategoryId);
    }

    // Update local state immediately for UI feedback
    state = AsyncValue.data(
      state.value!.copyWith(currentTransfers: newCurrent),
    );
  }

  Future<void> confirmTransfers() async {
    if (state.hasError || state.isLoading || state.value == null) return;

    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockNotifierProvider);
    final currentMap = state.value!.currentTransfers;

    // FIX 2: Correct capitalization for the date provider
    final currentDate = ref.read(weeklyDateProvider);

    state = const AsyncValue.loading();

    try {
      // 2. Clear old transfers for this target
      await repository.deleteBudgetTransfers(toCategory.id, clock.now());

      // 3. Save new transfers
      for (var entry in currentMap.entries) {
        final transfer = BudgetTransfer(
          id: '${entry.key}_${toCategory.id}_${clock.now().millisecondsSinceEpoch}',
          fromCategoryId: entry.key,
          toCategoryId: toCategory.id,
          amount: entry.value,
          date: clock.now(),
        );
        await repository.addBudgetTransfer(transfer);
      }

      // 4. UPDATE LOCAL STATE
      state = AsyncValue.data(
        TransferControllerState(
          initialTransfers: currentMap,
          currentTransfers: currentMap,
        ),
      );

      // 5. INVALIDATE DATA PROVIDER
      // We invalidate the weekly projection so the UI reflects the shifted variable funds
      ref.invalidate(weeklyCategoryDataProvider(selectedDate: currentDate));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
