// lib/src/core/presentation/utils/palette_generator.dart
import 'package:flutter/material.dart';

/// A data class holding the three-shade color palette for spending types.
class SpendingPalette {
  const SpendingPalette({
    required this.wallet,
    required this.recurring,
    required this.oneOff,
  });

  /// The lightest shade, used for wallet spending.
  final Color wallet;

  /// The medium shade, used for recurring spending.
  final Color recurring;

  /// The darkest shade, used for one-off spending.
  final Color oneOff;

  /// Returns colors in the order for legends: [Recurring, Wallet, One-Off].
  List<Color> get legendList => [wallet, recurring, oneOff];

  /// Returns colors for stacking in the historical chart: [One-Off, Recurring, Wallet].
  List<Color> get historicalChartList => [wallet, recurring, oneOff];
}

/// Generates a three-shade color palette from a single base color.
///
/// The color mapping is:
/// - Wallet: Lightest shade (the base color).
/// - Recurring: A medium shade, slightly darker than the base.
/// - One-Off: The darkest shade.
SpendingPalette generateSpendingPalette(Color baseColor) {
  final hslColor = HSLColor.fromColor(baseColor);

  final walletColor = baseColor; // Lightest

  final recurringColor = hslColor // Medium
      .withLightness((hslColor.lightness * 0.8).clamp(0.0, 1.0))
      .withSaturation((hslColor.saturation * 0.9).clamp(0.0, 1.0))
      .toColor();

  final oneOffColor = hslColor // Darkest
      .withLightness((hslColor.lightness * 0.6).clamp(0.0, 1.0))
      .withSaturation((hslColor.saturation * 0.8).clamp(0.0, 1.0))
      .toColor();

  return SpendingPalette(
    wallet: walletColor,
    recurring: recurringColor,
    oneOff: oneOffColor,
  );
}