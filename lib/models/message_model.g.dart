// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 3;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      websiteId: fields[1] as String,
      content: fields[2] as String,
      isUser: fields[3] as bool,
      timestamp: fields[4] as DateTime,
      sources: (fields[5] as List).cast<SourceReference>(),
      confidence: fields[6] as double?,
      isLoading: fields[7] as bool,
      noInfoFound: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.websiteId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isUser)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.sources)
      ..writeByte(6)
      ..write(obj.confidence)
      ..writeByte(7)
      ..write(obj.isLoading)
      ..writeByte(8)
      ..write(obj.noInfoFound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceReferenceAdapter extends TypeAdapter<SourceReference> {
  @override
  final int typeId = 4;

  @override
  SourceReference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SourceReference(
      pageId: fields[0] as String,
      pageTitle: fields[1] as String,
      pageUrl: fields[2] as String,
      excerpt: fields[3] as String,
      relevanceScore: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SourceReference obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.pageId)
      ..writeByte(1)
      ..write(obj.pageTitle)
      ..writeByte(2)
      ..write(obj.pageUrl)
      ..writeByte(3)
      ..write(obj.excerpt)
      ..writeByte(4)
      ..write(obj.relevanceScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceReferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
