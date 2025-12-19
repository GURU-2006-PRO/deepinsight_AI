// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PageModelAdapter extends TypeAdapter<PageModel> {
  @override
  final int typeId = 1;

  @override
  PageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PageModel(
      id: fields[0] as String,
      websiteId: fields[1] as String,
      url: fields[2] as String,
      title: fields[3] as String,
      content: fields[4] as String,
      chunks: (fields[5] as List).cast<String>(),
      metadata: (fields[6] as Map).cast<String, dynamic>(),
      crawledAt: fields[7] as DateTime,
      section: fields[8] as String?,
      embedding: (fields[9] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, PageModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.websiteId)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.chunks)
      ..writeByte(6)
      ..write(obj.metadata)
      ..writeByte(7)
      ..write(obj.crawledAt)
      ..writeByte(8)
      ..write(obj.section)
      ..writeByte(9)
      ..write(obj.embedding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChunkModelAdapter extends TypeAdapter<ChunkModel> {
  @override
  final int typeId = 2;

  @override
  ChunkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChunkModel(
      id: fields[0] as String,
      pageId: fields[1] as String,
      websiteId: fields[2] as String,
      text: fields[3] as String,
      pageTitle: fields[4] as String,
      pageUrl: fields[5] as String,
      position: fields[6] as int,
      importance: fields[7] as double,
      embedding: (fields[8] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChunkModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pageId)
      ..writeByte(2)
      ..write(obj.websiteId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.pageTitle)
      ..writeByte(5)
      ..write(obj.pageUrl)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.importance)
      ..writeByte(8)
      ..write(obj.embedding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChunkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
