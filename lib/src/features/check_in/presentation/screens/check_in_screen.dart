// lib/src/features/check_in/presentation/check_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/pages/check_in_boost_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/rollover_save_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/debt_rollover_page.dart'; // NEW IMPORT
import 'package:budgit/src/features/check_in/presentation/pages/confirmation_page.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/screens/streak_screen.dart';
import 'package:budgit/src/features/check_in/presentation/screens/streak_ended_screen.dart';
import 'package:budgit/src/features/check_in/presentation/pages/transaction_review_page.dart'; 

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Added DebtRolloverPage to the flow
  final List<Widget> _checkInPages = [
    const TransactionReviewPage(), 
    const CheckInBoostPage(),     
    const RolloverSavePage(),
    const DebtRolloverPage(), // NEW: Step 4
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

  void _onContinue() async {
    if (_currentPage < _checkInPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      final isSuccess = await ref.read(checkInControllerProvider.notifier).completeCheckIn();
      final newStreakCount = await ref.read(checkInStreakProvider.future);

      if (mounted) {
        Navigator.of(context).pop(); // Close the check-in screen
        
        if (isSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StreakScreen(streakCount: newStreakCount),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const StreakEndedScreen(),
            ),
          );
        }
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