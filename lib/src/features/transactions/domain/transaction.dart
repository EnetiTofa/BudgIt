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
    this.parentRecurringId,
    this.iconCodePoint,    // ADD THIS
    this.iconFontFamily,   // ADD THIS
  }) : super(id: id, notes: notes, createdAt: createdAt, amount: amount);

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

  @HiveField(9)
  final String? parentRecurringId;

  // ADD NEW HIVE FIELDS
  @HiveField(10)
  final int? iconCodePoint;

  @HiveField(11)
  final String? iconFontFamily;
}

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
    required this.recurrenceFrequency,
    required this.startDate,
    this.endDate,
    this.iconCodePoint,
    this.iconFontFamily,
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

  @HiveField(10, defaultValue: 1)
  final int recurrenceFrequency;

  @HiveField(11)
  final int? iconCodePoint;

  @HiveField(12)
  final String? iconFontFamily;

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
          parentRecurringId: id,
          amount: amount,
          notes: notes,
          createdAt: createdAt,
          date: currentDate,
          itemName: paymentName,
          store: payee,
          category: category,
          // PASS ICON DATA TO THE OCCURRENCE
          iconCodePoint: iconCodePoint,
          iconFontFamily: iconFontFamily,
        ),
      );

      switch (recurrence) {
        case RecurrencePeriod.daily:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + recurrenceFrequency);
          break;
        case RecurrencePeriod.weekly:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + (7 * recurrenceFrequency));
          break;
        case RecurrencePeriod.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + recurrenceFrequency, currentDate.day);
          break;
        case RecurrencePeriod.yearly:
          currentDate = DateTime(currentDate.year + recurrenceFrequency, currentDate.month, currentDate.day);
          break;
      }
    }
    return occurrences;
  }
}

// ... (OneOffIncome and RecurringIncome remain the same) ...
@HiveType(typeId: 5)
class OneOffIncome extends Transaction with HiveObjectMixin {
   OneOffIncome({
    required String id,
    required String notes,
    required DateTime createdAt,
    required double amount,
    required this.date,
    required this.source,
    required this.iconCodePoint, 
    this.iconFontFamily,
    this.isAdvanced = false,
    this.reference,
    this.parentRecurringId,
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

  @HiveField(7)
  final String? reference;
  @HiveField(8, defaultValue: 57534)
  final int iconCodePoint;
  @HiveField(9)
  final String? iconFontFamily;
  @HiveField(10)
  final String? parentRecurringId;
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
    required this.recurrenceFrequency,
    required this.startDate,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.endDate,
    this.isAdvanced = false,
    this.reference,
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

  @HiveField(9)
  final String? reference;
  @HiveField(10, defaultValue: 57534)
  final int iconCodePoint;
  @HiveField(11)
  final String? iconFontFamily;
  @HiveField(12, defaultValue: 1) 
  final int recurrenceFrequency;

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
          parentRecurringId: id,
          amount: amount,
          notes: notes,
          createdAt: createdAt,
          date: currentDate,
          source: source,
          isAdvanced: isAdvanced,
          reference: reference,
          iconCodePoint: iconCodePoint,
          iconFontFamily: iconFontFamily,
        ),
      );

      switch (recurrence) {
        case RecurrencePeriod.daily:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + recurrenceFrequency);
          break;
        case RecurrencePeriod.weekly:
          currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + (7 * recurrenceFrequency));
          break;
        case RecurrencePeriod.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + recurrenceFrequency, currentDate.day);
          break;
        case RecurrencePeriod.yearly:
          currentDate = DateTime(currentDate.year + recurrenceFrequency, currentDate.month, currentDate.day);
          break;
      }
    }
    return occurrences;
  }
}


@HiveType(typeId: 7)
class PaymentOccurrence extends OneOffPayment {
   PaymentOccurrence({
    required super.id,
    super.parentRecurringId,
    required super.notes,
    required super.createdAt,
    required super.amount,
    required super.date,
    required super.itemName,
    required super.store,
    required super.category,
    super.isWalleted = false,
    super.iconCodePoint,    // ADD THIS
    super.iconFontFamily,   // ADD THIS
  });
}

@HiveType(typeId: 8)
class IncomeOccurrence extends OneOffIncome {
  IncomeOccurrence({
    required super.id,
    super.parentRecurringId,
    required super.notes,
    required super.createdAt,
    required super.amount,
    required super.date,
    required super.source,
    required super.iconCodePoint,
    super.iconFontFamily,
    super.isAdvanced = false,
    super.reference,
  });
}