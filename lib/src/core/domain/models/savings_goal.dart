import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 10)
class SavingsGoal extends Equatable with HiveObjectMixin {
  SavingsGoal({
    required this.id,
    required this.targetAmount,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final double targetAmount;
  @HiveField(2)
  final DateTime createdAt;
  
  @override
  List<Object?> get props => [id, targetAmount, createdAt];
}