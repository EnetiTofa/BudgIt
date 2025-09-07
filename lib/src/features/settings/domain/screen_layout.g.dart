// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_layout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreenLayoutAdapter extends TypeAdapter<ScreenLayout> {
  @override
  final int typeId = 11;

  @override
  ScreenLayout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreenLayout(
      screenId: fields[0] as String,
      widgetOrder: (fields[1] as List).cast<String>(),
      defaultWidget: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScreenLayout obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.screenId)
      ..writeByte(1)
      ..write(obj.widgetOrder)
      ..writeByte(2)
      ..write(obj.defaultWidget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenLayoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
