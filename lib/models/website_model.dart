import 'package:hive/hive.dart';

part 'website_model.g.dart';

@HiveType(typeId: 0)
class WebsiteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final int pageCount;

  @HiveField(4)
  final DateTime crawledAt;

  @HiveField(5)
  final bool isComplete;

  @HiveField(6)
  final int totalChunks;

  @HiveField(7)
  final int totalTokens;

  WebsiteModel({
    required this.id,
    required this.url,
    required this.title,
    required this.pageCount,
    required this.crawledAt,
    this.isComplete = false,
    this.totalChunks = 0,
    this.totalTokens = 0,
  });

  WebsiteModel copyWith({
    String? id,
    String? url,
    String? title,
    int? pageCount,
    DateTime? crawledAt,
    bool? isComplete,
    int? totalChunks,
    int? totalTokens,
  }) {
    return WebsiteModel(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      crawledAt: crawledAt ?? this.crawledAt,
      isComplete: isComplete ?? this.isComplete,
      totalChunks: totalChunks ?? this.totalChunks,
      totalTokens: totalTokens ?? this.totalTokens,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
    'pageCount': pageCount,
    'crawledAt': crawledAt.toIso8601String(),
    'isComplete': isComplete,
    'totalChunks': totalChunks,
    'totalTokens': totalTokens,
  };

  factory WebsiteModel.fromJson(Map<String, dynamic> json) => WebsiteModel(
    id: json['id'],
    url: json['url'],
    title: json['title'],
    pageCount: json['pageCount'],
    crawledAt: DateTime.parse(json['crawledAt']),
    isComplete: json['isComplete'] ?? false,
    totalChunks: json['totalChunks'] ?? 0,
    totalTokens: json['totalTokens'] ?? 0,
  );
}
