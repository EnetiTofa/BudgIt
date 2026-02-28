// lib/src/features/budget_hub/domain/category_gauge_data.dart

import 'package:flutter/material.dart';

class GaugeSegment {
  final String label;
  final double amount;
  final Color color;

  const GaugeSegment({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class CategoryGaugeData {
  const CategoryGaugeData({
    required this.segments,
    required this.totalBudget,
    required this.totalSpent,
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double totalSpent;
}
