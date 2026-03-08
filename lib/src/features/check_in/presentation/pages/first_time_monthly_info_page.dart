import 'package:flutter/material.dart';

class FirstTimeMonthlyInfoPage extends StatefulWidget {
  const FirstTimeMonthlyInfoPage({super.key});

  @override
  State<FirstTimeMonthlyInfoPage> createState() =>
      _FirstTimeMonthlyInfoPageState();
}

class _FirstTimeMonthlyInfoPageState extends State<FirstTimeMonthlyInfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            "Catching Up",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Since you're logging this month manually, you'll need to add your older expenses once you reach the Dashboard.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Visual Demo of the App Bar Plus Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Look for this button:"),
                    const SizedBox(width: 16),
                    ScaleTransition(
                      scale: Tween(
                        begin: 1.0,
                        end: 1.3,
                      ).animate(_pulseController),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Select 'Add Transaction' to log any receipts from earlier this month.",
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
