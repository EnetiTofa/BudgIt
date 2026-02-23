// lib/src/features/dashboard/presentation/widgets/notices_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/screens/check_in_screen.dart';

class NoticesWidget extends ConsumerWidget {
  const NoticesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch if check-in is required
    final isCheckInAvailable = ref.watch(isCheckInAvailableProvider).valueOrNull ?? false;

    // 1. STATE: CHECK-IN REQUIRED (CTA Button)
    if (isCheckInAvailable) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CheckInScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            // Use Primary color to make it look like an active button
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Complete Weekly Check In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. STATE: STANDARD NOTICE (Summary/Done)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Feature!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'New Streak Calendar Added to Dashboard.', // This can be dynamic later
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Dismiss logic if needed
            },
            icon: const Icon(Icons.close, size: 18),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }
}