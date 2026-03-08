import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';

enum CheckInStatus { initial, loading, dataReady, completed }

enum RolloverDecision { save, rollover }

enum CheckInType { none, firstTime, weekly, monthly }

enum HistoricalHandling { logManually, prorate }

class CheckInState extends Equatable {
  const CheckInState({
    this.status = CheckInStatus.initial,
    this.type = CheckInType.none,
    this.unspentFundsByCategory = const {},
    this.overspentFundsByCategory = const {},
    this.decision = RolloverDecision.save,
    this.rolloverAmounts = const {},
    this.weekTransactions = const [],
    this.checkInWeekDate,
    this.checkInWeekTransfers = const [],
    this.debtStreaks = const {},
    this.rollingOverDebtCategoryIds = const {},
    this.firstTimeWeekHandling = HistoricalHandling.logManually,
    this.firstTimeMonthHandling = HistoricalHandling.prorate,
    // --- NEW: Tracks accepted permanent budget tweaks ---
    this.proposedCategoryTweaks = const {},
  });

  final CheckInStatus status;
  final CheckInType type;
  final Map<String, double> unspentFundsByCategory;
  final Map<String, double> overspentFundsByCategory;
  final RolloverDecision decision;
  final Map<String, double> rolloverAmounts;
  final List<Transaction> weekTransactions;
  final DateTime? checkInWeekDate;
  final List<BudgetTransfer> checkInWeekTransfers;
  final Map<String, int> debtStreaks;
  final Set<String> rollingOverDebtCategoryIds;
  final HistoricalHandling firstTimeWeekHandling;
  final HistoricalHandling firstTimeMonthHandling;

  // --- NEW FIELD ---
  final Map<String, double> proposedCategoryTweaks;

  CheckInState copyWith({
    CheckInStatus? status,
    CheckInType? type,
    Map<String, double>? unspentFundsByCategory,
    Map<String, double>? overspentFundsByCategory,
    RolloverDecision? decision,
    Map<String, double>? rolloverAmounts,
    List<Transaction>? weekTransactions,
    DateTime? checkInWeekDate,
    List<BudgetTransfer>? checkInWeekTransfers,
    Map<String, int>? debtStreaks,
    Set<String>? rollingOverDebtCategoryIds,
    HistoricalHandling? firstTimeWeekHandling,
    HistoricalHandling? firstTimeMonthHandling,
    Map<String, double>? proposedCategoryTweaks,
  }) {
    return CheckInState(
      status: status ?? this.status,
      type: type ?? this.type,
      unspentFundsByCategory:
          unspentFundsByCategory ?? this.unspentFundsByCategory,
      overspentFundsByCategory:
          overspentFundsByCategory ?? this.overspentFundsByCategory,
      decision: decision ?? this.decision,
      rolloverAmounts: rolloverAmounts ?? this.rolloverAmounts,
      weekTransactions: weekTransactions ?? this.weekTransactions,
      checkInWeekDate: checkInWeekDate ?? this.checkInWeekDate,
      checkInWeekTransfers: checkInWeekTransfers ?? this.checkInWeekTransfers,
      debtStreaks: debtStreaks ?? this.debtStreaks,
      rollingOverDebtCategoryIds:
          rollingOverDebtCategoryIds ?? this.rollingOverDebtCategoryIds,
      firstTimeWeekHandling:
          firstTimeWeekHandling ?? this.firstTimeWeekHandling,
      firstTimeMonthHandling:
          firstTimeMonthHandling ?? this.firstTimeMonthHandling,
      proposedCategoryTweaks:
          proposedCategoryTweaks ?? this.proposedCategoryTweaks,
    );
  }

  @override
  List<Object?> get props => [
    status,
    type,
    unspentFundsByCategory,
    overspentFundsByCategory,
    decision,
    rolloverAmounts,
    weekTransactions,
    checkInWeekDate,
    checkInWeekTransfers,
    debtStreaks,
    rollingOverDebtCategoryIds,
    firstTimeWeekHandling,
    firstTimeMonthHandling,
    proposedCategoryTweaks,
  ];
}
