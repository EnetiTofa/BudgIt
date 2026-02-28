// lib/src/features/budgets/domain/monthly_spending.dart
class MonthlySpending {
  const MonthlySpending({
    required this.date,
    required this.amount,
    this.categoryTotals = const {}, // Added default empty map
  });

  final DateTime date;
  final double amount;
  final Map<String, double> categoryTotals; // Added category tracking
}
