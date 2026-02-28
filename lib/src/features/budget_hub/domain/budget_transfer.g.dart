// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_transfer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetTransferAdapter extends TypeAdapter<BudgetTransfer> {
  @override
  final int typeId = 9;

  @override
  BudgetTransfer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetTransfer(
      id: fields[0] as String,
      fromCategoryId: fields[1] as String,
      toCategoryId: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetTransfer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromCategoryId)
      ..writeByte(2)
      ..write(obj.toCategoryId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetTransferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
