import 'package:flutter/material.dart';

/// A custom [ShapeDecoration] that creates a border with smoothed corners,
/// blending between a standard circular and a continuous "squircle" shape.
class SmoothedCornerDecoration extends ShapeDecoration {
  /// Creates a smoothed corner decoration.
  ///
  /// The [smoothing] factor controls the blend between a circular corner (0.0)
  /// and a continuous corner (1.0).
  SmoothedCornerDecoration({
    required Color color,
    double radius = 24.0,
    double smoothing = 0.5,
  }) : super(
          color: color,
          shape: ShapeBorder.lerp(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            smoothing,
          )!,
        );
}