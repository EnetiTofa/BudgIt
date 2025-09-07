import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/wallet_review_page.dart';
import 'package:budgit/src/features/check_in/presentation/rollover_save_page.dart';
import 'package:budgit/src/features/check_in/presentation/confirmation_page.dart';
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
  
  // --- This is the new back button logic ---
  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // If on the first page, exit the check-in
      Navigator.of(context).pop();
    }
  }

  void _onContinue() {
    if (_currentPage < _checkInPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      ref.read(checkInControllerProvider.notifier).completeCheckIn().then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StreakScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Check-in'),
        // --- This custom leading button overrides the default back button ---
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
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _onContinue,
          child: Text(_currentPage == _checkInPages.length - 1 ? 'Complete Check-in' : 'Continue'),
        ),
      ),
    );
  }
}