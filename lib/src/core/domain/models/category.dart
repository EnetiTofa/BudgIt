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
    required this.budgetAmount, // The unified monthly baseline amount
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double budgetAmount; // Represents the total unified monthly budget.

  @HiveField(4)
  final int iconCodePoint;

  @HiveField(5)
  final String? iconFontFamily;

  @HiveField(6)
  final int colorValue;

  @HiveField(7)
  final String? iconFontPackage;

  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily,
    fontPackage: iconFontPackage,
  );

  Color get color => Color(colorValue);

  Color get contentColor {
    final luminance = color.computeLuminance();
    return luminance < 0.6
        ? Colors.white
        : const Color(0xFF121212).withAlpha(210);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    budgetAmount,
    colorValue,
    iconCodePoint,
  ];

  Category copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
