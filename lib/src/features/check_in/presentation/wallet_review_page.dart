import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';

class WalletReviewPage extends ConsumerWidget {
  const WalletReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: switch (checkInState.status) {
          CheckInStatus.initial || CheckInStatus.loading => const CircularProgressIndicator(),
          CheckInStatus.dataReady => () { // Use a lambda to allow local variables
              // V-- This is the new calculation
              final totalUnspent = checkInState.unspentFundsByCategory.values
                  .fold(0.0, (sum, val) => sum + val);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Last Week\'s Wallet', style: textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(
                    'You have \$${totalUnspent.toStringAsFixed(2)} unspent.',
                    style: textTheme.titleLarge,
                  ),
                ],
              );
            }(), // Immediately invoke the lambda
          _ => const Text('Something went wrong.'),
        },
      ),
    );
  }
}