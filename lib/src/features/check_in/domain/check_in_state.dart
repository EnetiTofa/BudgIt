// lib/src/features/check_in/domain/check_in_state.dart
import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';

enum CheckInStatus { initial, loading, dataReady, completed }
enum RolloverDecision { save, rollover }

class CheckInState extends Equatable {
  const CheckInState({
    this.status = CheckInStatus.initial,
    this.unspentFundsByCategory = const {},
    this.overspentFundsByCategory = const {}, 
    this.decision = RolloverDecision.save,
    this.rolloverAmounts = const {},
    this.weekTransactions = const [], 
    this.checkInWeekDate, 
    this.checkInWeekBoosts = const [],
    this.debtStreaks = const {}, // NEW: Tracks consecutive weeks of debt
    this.rollingOverDebtCategoryIds = const {}, // NEW: Tracks user selection
  });

  final CheckInStatus status;
  final Map<String, double> unspentFundsByCategory;
  final Map<String, double> overspentFundsByCategory; 
  final RolloverDecision decision;
  final Map<String, double> rolloverAmounts;
  final List<Transaction> weekTransactions;
  final DateTime? checkInWeekDate; 
  final List<WalletAdjustment> checkInWeekBoosts;
  final Map<String, int> debtStreaks; // NEW
  final Set<String> rollingOverDebtCategoryIds; // NEW

  CheckInState copyWith({
    CheckInStatus? status,
    Map<String, double>? unspentFundsByCategory,
    Map<String, double>? overspentFundsByCategory,
    RolloverDecision? decision,
    Map<String, double>? rolloverAmounts,
    List<Transaction>? weekTransactions,
    DateTime? checkInWeekDate,
    List<WalletAdjustment>? checkInWeekBoosts,
    Map<String, int>? debtStreaks,
    Set<String>? rollingOverDebtCategoryIds,
  }) {
    return CheckInState(
      status: status ?? this.status,
      unspentFundsByCategory: unspentFundsByCategory ?? this.unspentFundsByCategory,
      overspentFundsByCategory: overspentFundsByCategory ?? this.overspentFundsByCategory,
      decision: decision ?? this.decision,
      rolloverAmounts: rolloverAmounts ?? this.rolloverAmounts,
      weekTransactions: weekTransactions ?? this.weekTransactions,
      checkInWeekDate: checkInWeekDate ?? this.checkInWeekDate,
      checkInWeekBoosts: checkInWeekBoosts ?? this.checkInWeekBoosts,
      debtStreaks: debtStreaks ?? this.debtStreaks,
      rollingOverDebtCategoryIds: rollingOverDebtCategoryIds ?? this.rollingOverDebtCategoryIds,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    unspentFundsByCategory, 
    overspentFundsByCategory,
    decision, 
    rolloverAmounts, 
    weekTransactions,
    checkInWeekDate,
    checkInWeekBoosts,
    debtStreaks,
    rollingOverDebtCategoryIds,
  ];
}