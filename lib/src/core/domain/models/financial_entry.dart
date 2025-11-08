// We need to make this class extend HiveObject
abstract class FinancialEntry {
  const FinancialEntry({
    required this.id,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String notes;
  final DateTime createdAt;
}