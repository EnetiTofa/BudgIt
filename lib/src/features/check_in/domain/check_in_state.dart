import 'package:equatable/equatable.dart';

enum CheckInStatus { initial, loading, dataReady, completed }
enum RolloverDecision { save, rollover } // Simplified

class CheckInState extends Equatable {
  const CheckInState({
    this.status = CheckInStatus.initial,
    this.unspentFundsByCategory = const {},
    this.decision = RolloverDecision.save, // Default to Save
    this.rolloverAmounts = const {},
  });

  final CheckInStatus status;
  final Map<String, double> unspentFundsByCategory;
  final RolloverDecision decision;
  final Map<String, double> rolloverAmounts;
  
  // --- This is the corrected copyWith method ---
  CheckInState copyWith({
    CheckInStatus? status,
    Map<String, double>? unspentFundsByCategory,
    RolloverDecision? decision,
    Map<String, double>? rolloverAmounts,
  }) {
    return CheckInState(
      status: status ?? this.status,
      unspentFundsByCategory: unspentFundsByCategory ?? this.unspentFundsByCategory,
      decision: decision ?? this.decision,
      rolloverAmounts: rolloverAmounts ?? this.rolloverAmounts,
    );
  }

  // --- This is the corrected props getter ---
  @override
  List<Object?> get props => [status, unspentFundsByCategory, decision, rolloverAmounts];
}