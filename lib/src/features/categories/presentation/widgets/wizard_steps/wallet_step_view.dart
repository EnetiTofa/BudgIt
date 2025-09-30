// lib/src/features/categories/presentation/widgets/wizard_steps/wallet_step_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/features/categories/presentation/controllers/add_category_controller.dart';

class WalletStepView extends ConsumerStatefulWidget {
  const WalletStepView({super.key});

  @override
  ConsumerState<WalletStepView> createState() => _WalletStepViewState();
}

class _WalletStepViewState extends ConsumerState<WalletStepView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialValue = ref.read(addCategoryControllerProvider).walletAmount;
    if (initialValue != null) {
      _controller.text = initialValue.toStringAsFixed(2);
    }
    // Add a listener that triggers when focus changes.
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // If the field has lost focus, update the provider.
    if (!_focusNode.hasFocus) {
      final value = double.tryParse(_controller.text) ?? 0.0;
      ref.read(addCategoryControllerProvider.notifier).setWallet(value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCategoryControllerProvider);
    final notifier = ref.read(addCategoryControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Set a weekly wallet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "This is your allowance for day-to-day spending, like coffee or lunch.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          CurrencyInputField(
            labelText: 'Weekly Wallet Amount',
            initialValue: state.walletAmount ?? 0.0,
            onChanged: (value) {
              // Schedule the provider update to run after the build is complete.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.setWallet(value);
              });
            },
          ),
        ],
      ),
    );
  }
}