// lib/src/features/dashboard/presentation/dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/dashboard/presentation/widgets/dashboard_weekly_widget.dart';
import 'package:budgit/src/features/dashboard/presentation/widgets/notices_widget.dart';
import 'package:budgit/src/features/dashboard/presentation/widgets/streak_counter_widget.dart'; // New Import

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        NoticesWidget(),
        SizedBox(height: 16),

        DashboardWeeklyWidget(),

        SizedBox(height: 16),

        StreakCounterWidget(),
      ],
    );
  }
}
