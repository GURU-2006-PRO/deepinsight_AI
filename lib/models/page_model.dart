import 'package:hive/hive.dart';

part 'page_model.g.dart';

@HiveType(typeId: 1)
class PageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String websiteId;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final List<String> chunks;

  @HiveField(6)
  final Map<String, dynamic> metadata;

  @HiveField(7)
  final DateTime crawledAt;

  @HiveField(8)
  final String? section;

  @HiveField(9)
  final List<double>? embedding;

  PageModel({
    required this.id,
    required this.websiteId,
    required this.url,
    required this.title,
    required this.content,
    required this.chunks,
    required this.metadata,
    required this.crawledAt,
    this.section,
    this.embedding,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'websiteId': websiteId,
    'url': url,
    'title': title,
    'content': content,
    'chunks': chunks,
    'metadata': metadata,
    'crawledAt': crawledAt.toIso8601String(),
    'section': section,
  };

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
    id: json['id'],
    websiteId: json['websiteId'],
    url: json['url'],
    title: json['title'] ?? 'Untitled',
    content: json['content'] ?? '',
    chunks: List<String>.from(json['chunks'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    crawledAt: DateTime.parse(json['crawledAt']),
    section: json['section'],
  );
}

@HiveType(typeId: 2)
class ChunkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pageId;

  @HiveField(2)
  final String websiteId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String pageTitle;

  @HiveField(5)
  final String pageUrl;

  @HiveField(6)
  final int position;

  @HiveField(7)
  final double importance;

  @HiveField(8)
  final List<double>? embedding;

  ChunkModel({
    required this.id,
    required this.pageId,
    required this.websiteId,
    required this.text,
    required this.pageTitle,
    required this.pageUrl,
    required this.position,
    this.importance = 1.0,
    this.embedding,
  });

  ChunkModel copyWith({
    String? id,
    String? pageId,
    String? websiteId,
    String? text,
    String? pageTitle,
    String? pageUrl,
    int? position,
    double? importance,
    List<double>? embedding,
  }) {
    return ChunkModel(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      websiteId: websiteId ?? this.websiteId,
      text: text ?? this.text,
      pageTitle: pageTitle ?? this.pageTitle,
      pageUrl: pageUrl ?? this.pageUrl,
      position: position ?? this.position,
      importance: importance ?? this.importance,
      embedding: embedding ?? this.embedding,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageId': pageId,
    'websiteId': websiteId,
    'text': text,
    'pageTitle': pageTitle,
    'pageUrl': pageUrl,
    'position': position,
    'importance': importance,
  };
}
