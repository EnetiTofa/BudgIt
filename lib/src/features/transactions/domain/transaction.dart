import 'package:hive/hive.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/financial_entry.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
enum RecurrencePeriod {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly
}

// Abstract class has no Hive code
abstract class Transaction extends FinancialEntry {
  const Transaction({
    required super.id,
    required super.notes,
    required super.createdAt,
    required this.amount,
  });

  final double amount;
}

@HiveType(typeId: 3)
class OneOffPayment extends Transaction with HiveObjectMixin {
  OneOffPayment({
    required String id,
    required String notes,
    required DateTime createdAt,
    required double amount,
    required this.date,
    required this.itemName,
    required this.store,
    required this.category,
    this.isWalleted = false,
  }) : super(id: id, notes: notes, createdAt: createdAt, amount: amount);

  // Fields specific to this class
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final String itemName;
  @HiveField(2)
  final String store;
  @HiveField(3)
  final Category category;
  @HiveField(4)
  final bool isWalleted;

  // Overridden fields from superclasses
  @override
  @HiveField(5)
  String get id => super.id;

  @override
  @HiveField(6)
  String get notes => super.notes;

  @override
  @HiveField(7)
  DateTime get createdAt => super.createdAt;
  
  @override
  @HiveField(8)
  double get amount => super.amount;
}


// --- Apply the same pattern to all other concrete classes ---

@HiveType(typeId: 4)
class RecurringPayment extends Transaction with HiveObjectMixin {
  RecurringPayment({
    required String id,
    required String notes,
    required DateTime createdAt,
    required double amount,
    required this.paymentName,
    required this.payee,
    required this.category,
    required this.recurrence,
    required this.startDate,
    this.endDate,
  }) : super(id: id, notes: notes, createdAt: createdAt, amount: amount);

  @HiveField(0)
  final String paymentName;
  @HiveField(1)
  final String payee;
  @HiveField(2)
  final Category category;
  @HiveField(3)
  final RecurrencePeriod recurrence;
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime? endDate;

  @override @HiveField(6) String get id => super.id;
  @override @HiveField(7) String get notes => super.notes;
  @override @HiveField(8) DateTime get createdAt => super.createdAt;
  @override @HiveField(9) double get amount => super.amount;

  List<PaymentOccurrence> generateOccurrences({required DateTime upToDate}) {
    final occurrences = <PaymentOccurrence>[];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(upToDate) || currentDate.isAtSameMomentAs(upToDate)) {
      if (endDate != null && currentDate.isAfter(endDate!)) {
        break;
      }

      occurrences.add(
        PaymentOccurrence(
          id: '${id}_${currentDate.toIso8601String()}',
          amount: amount,
          notes: notes,
          createdAt: createdAt,
          date: currentDate,
          itemName: paymentName,
          store: payee,
          category: category,
        ),
      );

      switch (recurrence) {
        case RecurrencePeriod.daily:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
          break;
        case RecurrencePeriod.weekly:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 7);
          break;
        case RecurrencePeriod.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case RecurrencePeriod.yearly:
          currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
          break;
      }
    }
    return occurrences;
  }
}

@HiveType(typeId: 5)
class OneOffIncome extends Transaction with HiveObjectMixin {
   OneOffIncome({
    required String id,
    required String notes,
    required DateTime createdAt,
    required double amount,
    required this.date,
    required this.source,
    this.isAdvanced = false,
  }) : super(id: id, notes: notes, createdAt: createdAt, amount: amount);

  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final String source;
  @HiveField(2)
  final bool isAdvanced;

  @override @HiveField(3) String get id => super.id;
  @override @HiveField(4) String get notes => super.notes;
  @override @HiveField(5) DateTime get createdAt => super.createdAt;
  @override @HiveField(6) double get amount => super.amount;
}

@HiveType(typeId: 6)
class RecurringIncome extends Transaction with HiveObjectMixin {
  RecurringIncome({
    required String id,
    required String notes,
    required DateTime createdAt,
    required double amount,
    required this.source,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    this.isAdvanced = false,
  }) : super(id: id, notes: notes, createdAt: createdAt, amount: amount);

  @HiveField(0)
  final String source;
  @HiveField(1)
  final RecurrencePeriod recurrence;
  @HiveField(2)
  final DateTime startDate;
  @HiveField(3)
  final DateTime? endDate;
  @HiveField(4)
  final bool isAdvanced;

  @override @HiveField(5) String get id => super.id;
  @override @HiveField(6) String get notes => super.notes;
  @override @HiveField(7) DateTime get createdAt => super.createdAt;
  @override @HiveField(8) double get amount => super.amount;
  
  List<IncomeOccurrence> generateOccurrences({required DateTime upToDate}) {
    final occurrences = <IncomeOccurrence>[];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(upToDate) || currentDate.isAtSameMomentAs(upToDate)) {
      if (endDate != null && currentDate.isAfter(endDate!)) {
        break;
      }

      occurrences.add(
        IncomeOccurrence(
          id: '${id}_${currentDate.toIso8601String()}',
          amount: amount,
          notes: notes,
          createdAt: createdAt,
          date: currentDate,
          source: source,
        ),
      );

      switch (recurrence) {
        case RecurrencePeriod.daily:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
          break;
        case RecurrencePeriod.weekly:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 7);
          break;
        case RecurrencePeriod.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case RecurrencePeriod.yearly:
          currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
          break;
      }
    }
    return occurrences;
  }
}

// Occurrence classes are not stored directly, so they don't need Hive annotations
@HiveType(typeId: 7)
class PaymentOccurrence extends OneOffPayment {
   PaymentOccurrence({
    required super.id,
    required super.notes,
    required super.createdAt,
    required super.amount,
    required super.date,
    required super.itemName,
    required super.store,
    required super.category,
    super.isWalleted = false,
  });
}

@HiveType(typeId: 8)
class IncomeOccurrence extends OneOffIncome {
  IncomeOccurrence({
    required super.id,
    required super.notes,
    required super.createdAt,
    required super.amount,
    required super.date,
    required super.source,
    super.isAdvanced = false,
  });
}