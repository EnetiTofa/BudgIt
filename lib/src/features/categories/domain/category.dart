import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart'; // Make sure this import is here

part 'category.g.dart';

@HiveType(typeId: 1)
enum BudgetPeriod { 
  @HiveField(0)
  weekly, 
  @HiveField(1)
  monthly, 
  @HiveField(2)
  yearly 
}

@HiveType(typeId: 0)
// V-- This line is the most important part
class Category extends Equatable with HiveObjectMixin { 
  Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.colorValue,
    required this.budgetAmount,
    required this.budgetPeriod,
    this.walletAmount,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double budgetAmount;
  @HiveField(3)
  final BudgetPeriod budgetPeriod;
  @HiveField(4)
  final double? walletAmount;
  @HiveField(5)
  final int iconCodePoint;
  @HiveField(6)
  final String? iconFontFamily;
  @HiveField(7)
  final int colorValue;

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
  Color get color => Color(colorValue);

  // This is also required for Equatable to work
  @override
  List<Object?> get props => [id];
}