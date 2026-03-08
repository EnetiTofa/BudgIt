import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';

// --- Existing Pages ---
import 'package:budgit/src/features/check_in/presentation/pages/transaction_review_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/check_in_transfer_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/rollover_save_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/debt_rollover_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/confirmation_page.dart';
import 'package:budgit/src/features/check_in/presentation/screens/streak_screen.dart';
import 'package:budgit/src/features/check_in/presentation/screens/streak_ended_screen.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_day_picker_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_intro_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_income_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_category_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_prorate_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_weekly_log_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_monthly_info_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/first_time_confirmation_page.dart';
// REMOVED: monthly_debt_acknowledgment_page.dart
import 'package:budgit/src/features/check_in/presentation/pages/transition_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/monthly_review_page.dart';
import 'package:budgit/src/features/check_in/presentation/pages/smart_proposals_page.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // We only store the type here instead of the whole page list
  CheckInType? _checkInType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Determine what kind of check-in this is
      final checkInType = await ref.read(isCheckInAvailableProvider.future);

      if (!mounted) return;

      // 2. Set the type so the UI can build the correct flow
      setState(() {
        _checkInType = checkInType;
      });

      // 3. Initialize the controller data
      ref
          .read(checkInControllerProvider.notifier)
          .startCheckIn(type: checkInType);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- THE MAGIC: Dynamically build the page list based on state ---
  List<Widget> _buildPages(CheckInType type, dynamic state) {
    switch (type) {
      case CheckInType.firstTime:
        return [
          const FirstTimeIntroPage(), // 1
          const FirstTimeDayPickerPage(), // 2
          const FirstTimeIncomePage(), // 3
          const FirstTimeCategoryPage(), // 4
          const FirstTimeProratePage(), // 5
          // Dynamically insert Weekly Log if selected
          if (state.firstTimeWeekHandling == HistoricalHandling.logManually)
            const FirstTimeWeeklyLogPage(),

          // Dynamically insert Monthly Info if selected (flows perfectly after week if both are selected)
          if (state.firstTimeMonthHandling == HistoricalHandling.logManually)
            const FirstTimeMonthlyInfoPage(),

          const FirstTimeConfirmationPage(), // Final
        ];

      case CheckInType.monthly:
        return [
          const TransactionReviewPage(),
          const CheckInTransferPage(),
          const RolloverSavePage(),
          const DebtRolloverPage(),
          TransitionPage(onAutoAdvance: _onContinue),
          const MonthlyReviewPage(),
          const SmartProposalsPage(),
        ];

      case CheckInType.weekly:
      case CheckInType.none:
        return const [
          TransactionReviewPage(),
          CheckInTransferPage(),
          RolloverSavePage(),
          DebtRolloverPage(),
          ConfirmationPage(),
        ];
    }
  }

  String _getAppBarTitle(CheckInType type) {
    switch (type) {
      case CheckInType.firstTime:
        return "Welcome to BudgIt";
      case CheckInType.monthly:
        return "Monthly Check-In";
      case CheckInType.weekly:
      case CheckInType.none:
        return "Weekly Check-In";
    }
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
    final state = ref.read(checkInControllerProvider);
    final currentPages = _buildPages(_checkInType!, state);

    if (_currentPage < currentPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // --- THE FIX: Pass _checkInType explicitly! ---
      final isSuccess = await ref
          .read(checkInControllerProvider.notifier)
          .completeCheckIn(explicitType: _checkInType);

      if (mounted) {
        Navigator.of(context).pop();

        if (_checkInType != CheckInType.firstTime) {
          final newStreakCount = await ref.read(checkInStreakProvider.future);

          if (isSuccess) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StreakScreen(streakCount: newStreakCount),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StreakEndedScreen()),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loader until the check-in type is resolved
    if (_checkInType == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Watch the state so the PageView rebuilds if the user taps a different radio button!
    final state = ref.watch(checkInControllerProvider);
    final checkInPages = _buildPages(_checkInType!, state);
    final appBarTitle = _getAppBarTitle(_checkInType!);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: checkInPages,
      ),
      bottomNavigationBar: checkInPages[_currentPage] is TransitionPage
          ? const SizedBox.shrink() // Hides the button entirely during the transition
          : Padding(
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
                    _currentPage == checkInPages.length - 1
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
