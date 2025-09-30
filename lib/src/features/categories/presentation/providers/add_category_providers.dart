import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';

part 'add_category_providers.g.dart';

@riverpod
class TempRecurringPayments extends _$TempRecurringPayments {
  @override
  List<RecurringPayment> build() {
    return [];
  }

  void addPayment(RecurringPayment payment) {
    state = [...state, payment];
  }

  void removePayment(String paymentId) {
    state = state.where((p) => p.id != paymentId).toList();
  }

  // ADD THIS METHOD
  void updatePayment(RecurringPayment updatedPayment) {
    state = [
      for (final payment in state)
        if (payment.id == updatedPayment.id) updatedPayment else payment,
    ];
  }
}