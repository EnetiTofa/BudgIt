// lib/src/features/check_in/presentation/check_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/wallet_review_page.dart';
import 'package:budgit/src/features/check_in/presentation/rollover_save_page.dart';
import 'package:budgit/src/features/check_in/presentation/confirmation_page.dart';
import 'package:budgit/src/features/check_in/presentation/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/streak_screen.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _checkInPages = [
    const WalletReviewPage(),
    const RolloverSavePage(),
    const ConfirmationPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkInControllerProvider.notifier).startCheckIn();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  // --- THIS IS THE CORRECTED NAVIGATION LOGIC ---
  void _onContinue() async {
    if (_currentPage < _checkInPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // 1. Await the controller method that updates the database
      await ref.read(checkInControllerProvider.notifier).completeCheckIn();

      // 2. Read the provider again to get the NEW value after invalidation
      final newStreakCount = await ref.read(checkInStreakProvider.future);

      // 3. Navigate, passing the confirmed new value to the StreakScreen
      if (mounted) {
        Navigator.of(context).pop(); // Close the check-in screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StreakScreen(streakCount: newStreakCount),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Check-in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: _checkInPages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              _currentPage == _checkInPages.length - 1
                  ? 'Complete Check-in'
                  : 'Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}