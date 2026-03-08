// lib/src/core/data/providers/custom_payees_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'custom_payees_provider.g.dart';

// --- ADDED keepAlive: true ---
@Riverpod(keepAlive: true)
class CustomPayees extends _$CustomPayees {
  @override
  List<String> build() {
    return [];
  }

  void addPayee(String payee) {
    final trimmed = payee.trim();
    if (trimmed.isNotEmpty && !state.contains(trimmed)) {
      state = [...state, trimmed];
    }
  }

  void removePayee(String payee) {
    state = state.where((p) => p != payee).toList();
  }
}
