import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/streak_provider.dart';

class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  @override
  void initState() {
    super.initState();
    // Start a 3-second timer when the screen is first built.
    Timer(const Duration(seconds: 3), () {
      // When the timer finishes, pop the screen, but only if it's still
      // visible on screen to prevent errors.
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(checkInStreakProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 80),
            const SizedBox(height: 16),
            Text('Check-in Complete!', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            streakAsync.when(
              data: (streak) => Text(
                '$streak week streak!',
                style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => const Text('Could not load streak'),
            ),
          ],
        ),
      ),
    );
  }
}