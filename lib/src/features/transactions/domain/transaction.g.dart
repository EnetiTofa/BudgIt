// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OneOffPaymentAdapter extends TypeAdapter<OneOffPayment> {
  @override
  final int typeId = 3;

  @override
  OneOffPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OneOffPayment(
      id: fields[5] as String,
      notes: fields[6] as String,
      createdAt: fields[7] as DateTime,
      amount: fields[8] as double,
      date: fields[0] as DateTime,
      itemName: fields[1] as String,
      store: fields[2] as String,
      category: fields[3] as Category,
      isWalleted: fields[4] as bool,
      parentRecurringId: fields[9] as String?,
      iconCodePoint: fields[10] as int?,
      iconFontFamily: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OneOffPayment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.store)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isWalleted)
      ..writeByte(9)
      ..write(obj.parentRecurringId)
      ..writeByte(10)
      ..write(obj.iconCodePoint)
      ..writeByte(11)
      ..write(obj.iconFontFamily)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OneOffPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringPaymentAdapter extends TypeAdapter<RecurringPayment> {
  @override
  final int typeId = 4;

  @override
  RecurringPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringPayment(
      id: fields[6] as String,
      notes: fields[7] as String,
      createdAt: fields[8] as DateTime,
      amount: fields[9] as double,
      paymentName: fields[0] as String,
      payee: fields[1] as String,
      category: fields[2] as Category,
      recurrence: fields[3] as RecurrencePeriod,
      recurrenceFrequency: fields[10] == null ? 1 : fields[10] as int,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      iconCodePoint: fields[11] as int?,
      iconFontFamily: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringPayment obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.paymentName)
      ..writeByte(1)
      ..write(obj.payee)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.recurrence)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.recurrenceFrequency)
      ..writeByte(11)
      ..write(obj.iconCodePoint)
      ..writeByte(12)
      ..write(obj.iconFontFamily)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OneOffIncomeAdapter extends TypeAdapter<OneOffIncome> {
  @override
  final int typeId = 5;

  @override
  OneOffIncome read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OneOffIncome(
      id: fields[3] as String,
      notes: fields[4] as String,
      createdAt: fields[5] as DateTime,
      amount: fields[6] as double,
      date: fields[0] as DateTime,
      source: fields[1] as String,
      iconCodePoint: fields[8] == null ? 57534 : fields[8] as int,
      iconFontFamily: fields[9] as String?,
      isAdvanced: fields[2] as bool,
      reference: fields[7] as String?,
      parentRecurringId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OneOffIncome obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.source)
      ..writeByte(2)
      ..write(obj.isAdvanced)
      ..writeByte(7)
      ..write(obj.reference)
      ..writeByte(8)
      ..write(obj.iconCodePoint)
      ..writeByte(9)
      ..write(obj.iconFontFamily)
      ..writeByte(10)
      ..write(obj.parentRecurringId)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OneOffIncomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringIncomeAdapter extends TypeAdapter<RecurringIncome> {
  @override
  final int typeId = 6;

  @override
  RecurringIncome read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringIncome(
      id: fields[5] as String,
      notes: fields[6] as String,
      createdAt: fields[7] as DateTime,
      amount: fields[8] as double,
      source: fields[0] as String,
      recurrence: fields[1] as RecurrencePeriod,
      recurrenceFrequency: fields[12] == null ? 1 : fields[12] as int,
      startDate: fields[2] as DateTime,
      iconCodePoint: fields[10] == null ? 57534 : fields[10] as int,
      iconFontFamily: fields[11] as String?,
      endDate: fields[3] as DateTime?,
      isAdvanced: fields[4] as bool,
      reference: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringIncome obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.source)
      ..writeByte(1)
      ..write(obj.recurrence)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.isAdvanced)
      ..writeByte(9)
      ..write(obj.reference)
      ..writeByte(10)
      ..write(obj.iconCodePoint)
      ..writeByte(11)
      ..write(obj.iconFontFamily)
      ..writeByte(12)
      ..write(obj.recurrenceFrequency)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringIncomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentOccurrenceAdapter extends TypeAdapter<PaymentOccurrence> {
  @override
  final int typeId = 7;

  @override
  PaymentOccurrence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentOccurrence(
      id: fields[5] as String,
      parentRecurringId: fields[9] as String?,
      notes: fields[6] as String,
      createdAt: fields[7] as DateTime,
      amount: fields[8] as double,
      date: fields[0] as DateTime,
      itemName: fields[1] as String,
      store: fields[2] as String,
      category: fields[3] as Category,
      isWalleted: fields[4] as bool,
      iconCodePoint: fields[10] as int?,
      iconFontFamily: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentOccurrence obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.store)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isWalleted)
      ..writeByte(9)
      ..write(obj.parentRecurringId)
      ..writeByte(10)
      ..write(obj.iconCodePoint)
      ..writeByte(11)
      ..write(obj.iconFontFamily)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentOccurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncomeOccurrenceAdapter extends TypeAdapter<IncomeOccurrence> {
  @override
  final int typeId = 8;

  @override
  IncomeOccurrence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncomeOccurrence(
      id: fields[3] as String,
      parentRecurringId: fields[10] as String?,
      notes: fields[4] as String,
      createdAt: fields[5] as DateTime,
      amount: fields[6] as double,
      date: fields[0] as DateTime,
      source: fields[1] as String,
      iconCodePoint: fields[8] == null ? 57534 : fields[8] as int,
      iconFontFamily: fields[9] as String?,
      isAdvanced: fields[2] as bool,
      reference: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeOccurrence obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.source)
      ..writeByte(2)
      ..write(obj.isAdvanced)
      ..writeByte(7)
      ..write(obj.reference)
      ..writeByte(8)
      ..write(obj.iconCodePoint)
      ..writeByte(9)
      ..write(obj.iconFontFamily)
      ..writeByte(10)
      ..write(obj.parentRecurringId)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeOccurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrencePeriodAdapter extends TypeAdapter<RecurrencePeriod> {
  @override
  final int typeId = 2;

  @override
  RecurrencePeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrencePeriod.daily;
      case 1:
        return RecurrencePeriod.weekly;
      case 2:
        return RecurrencePeriod.monthly;
      case 3:
        return RecurrencePeriod.yearly;
      default:
        return RecurrencePeriod.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrencePeriod obj) {
    switch (obj) {
      case RecurrencePeriod.daily:
        writer.writeByte(0);
        break;
      case RecurrencePeriod.weekly:
        writer.writeByte(1);
        break;
      case RecurrencePeriod.monthly:
        writer.writeByte(2);
        break;
      case RecurrencePeriod.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrencePeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
