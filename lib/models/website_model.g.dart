// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WebsiteModelAdapter extends TypeAdapter<WebsiteModel> {
  @override
  final int typeId = 0;

  @override
  WebsiteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebsiteModel(
      id: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      pageCount: fields[3] as int,
      crawledAt: fields[4] as DateTime,
      isComplete: fields[5] as bool,
      totalChunks: fields[6] as int,
      totalTokens: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WebsiteModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.pageCount)
      ..writeByte(4)
      ..write(obj.crawledAt)
      ..writeByte(5)
      ..write(obj.isComplete)
      ..writeByte(6)
      ..write(obj.totalChunks)
      ..writeByte(7)
      ..write(obj.totalTokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebsiteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
