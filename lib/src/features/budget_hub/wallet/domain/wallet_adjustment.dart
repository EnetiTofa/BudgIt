import 'package:hive/hive.dart';

part 'wallet_adjustment.g.dart';

@HiveType(typeId: 9)
class WalletAdjustment extends HiveObject {
  WalletAdjustment({
    required this.id,
    required this.fromCategoryId,
    required this.toCategoryId,
    required this.amount,
    required this.date,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fromCategoryId;
  @HiveField(2)
  final String toCategoryId;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final DateTime date;
}