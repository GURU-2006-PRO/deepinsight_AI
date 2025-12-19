import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 3)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String websiteId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final bool isUser;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final List<SourceReference> sources;

  @HiveField(6)
  final double? confidence;

  @HiveField(7)
  final bool isLoading;

  @HiveField(8)
  final bool noInfoFound;

  MessageModel({
    required this.id,
    required this.websiteId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sources = const [],
    this.confidence,
    this.isLoading = false,
    this.noInfoFound = false,
  });

  MessageModel copyWith({
    String? id,
    String? websiteId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<SourceReference>? sources,
    double? confidence,
    bool? isLoading,
    bool? noInfoFound,
  }) {
    return MessageModel(
      id: id ?? this.id,
      websiteId: websiteId ?? this.websiteId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      confidence: confidence ?? this.confidence,
      isLoading: isLoading ?? this.isLoading,
      noInfoFound: noInfoFound ?? this.noInfoFound,
    );
  }
}

@HiveType(typeId: 4)
class SourceReference extends HiveObject {
  @HiveField(0)
  final String pageId;

  @HiveField(1)
  final String pageTitle;

  @HiveField(2)
  final String pageUrl;

  @HiveField(3)
  final String excerpt;

  @HiveField(4)
  final double relevanceScore;

  SourceReference({
    required this.pageId,
    required this.pageTitle,
    required this.pageUrl,
    required this.excerpt,
    this.relevanceScore = 0.0,
  });
}
