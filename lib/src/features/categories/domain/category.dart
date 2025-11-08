// lib/src/features/categories/domain/category.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends Equatable with HiveObjectMixin {
  Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.colorValue,
    required this.budgetAmount, // This amount is ALWAYS monthly
    this.walletAmount,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double budgetAmount; // Represents the total monthly budget.
  
  @HiveField(3)
  final double? walletAmount;
  @HiveField(4)
  final int iconCodePoint;
  @HiveField(5)
  final String? iconFontFamily;
  @HiveField(6)
  final int colorValue;
  @HiveField(7) // ADD THIS
  final String? iconFontPackage;

  IconData get icon => IconData(
    iconCodePoint, 
    fontFamily: iconFontFamily, 
    fontPackage: iconFontPackage,
    );
  Color get color => Color(colorValue);

  // --- MODIFICATION: Updated the luminance threshold and alpha value ---
  Color get contentColor {
    // computeLuminance() returns a value from 0.0 (black) to 1.0 (white).
    final luminance = color.computeLuminance();
    // If the background is darker than the threshold (0.3), use white.
    // Otherwise, use a dark gray for better readability on light colors.
    return luminance < 0.6
        ? Colors.white
        : const Color(0xFF121212).withAlpha(210);
  }

  @override
  List<Object?> get props => [id];

  Category copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    double? walletAmount,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      walletAmount: walletAmount ?? this.walletAmount,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}