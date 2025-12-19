import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirecrawlService {
  static const String _baseUrl = 'https://api.firecrawl.dev/v1';
  final String apiKey;

  FirecrawlService({required this.apiKey});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  /// Get sitemap structure for smart selection
  Future<SitemapResult> mapWebsite(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/map'),
        headers: _headers,
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SitemapResult.fromJson(data);
      } else {
        throw FirecrawlException('Failed to map website: ${response.body}');
      }
    } catch (e) {
      throw FirecrawlException('Network error: $e');
    }
  }

  /// Start optimized website crawl
  Future<String> startCrawl(String url, {int? maxPages, List<String>? includePaths}) async {
    try {
      // Optimized configuration for best results
      final body = {
        'url': url,
        'limit': maxPages ?? 30,
        'scrapeOptions': {
          'formats': ['markdown'],
          'onlyMainContent': true,
          'includeTags': ['article', 'main', 'section', 'div'],
          'excludeTags': ['nav', 'footer', 'header', 'aside', 'script', 'style'],
          'waitFor': 2000, // Wait for dynamic content
        },
      };

      if (includePaths != null && includePaths.isNotEmpty) {
        body['includePaths'] = includePaths;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/crawl'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String;
      } else if (response.statusCode == 402) {
        throw FirecrawlException('API quota exceeded');
      } else if (response.statusCode == 401) {
        throw FirecrawlException('Invalid API key');
      } else {
        throw FirecrawlException('Crawl failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FirecrawlException) rethrow;
      throw FirecrawlException('Network error: $e');
    }
  }

  /// Check crawl status
  Future<CrawlStatus> getCrawlStatus(String crawlId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/crawl/$crawlId'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CrawlStatus.fromJson(data);
    } else {
      throw FirecrawlException('Status check failed: ${response.statusCode}');
    }
  }

  /// Scrape a single page
  Future<ScrapedPage> scrapePage(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scrape'),
        headers: _headers,
        body: jsonEncode({
          'url': url,
          'formats': ['markdown', 'html'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ScrapedPage.fromJson(data['data']);
      } else {
        throw FirecrawlException('Failed to scrape page: ${response.body}');
      }
    } catch (e) {
      if (e is FirecrawlException) rethrow;
      throw FirecrawlException('Network error: $e');
    }
  }

  /// Stream crawl progress efficiently
  Stream<CrawlStatus> streamCrawlProgress(
    String crawlId, {
    Duration interval = const Duration(seconds: 2),
  }) async* {
    while (true) {
      final status = await getCrawlStatus(crawlId);
      yield status;

      if (status.isComplete || status.isFailed) {
        break;
      }

      await Future.delayed(interval);
    }
  }
}

class SitemapResult {
  final List<String> links;
  final int totalPages;

  SitemapResult({required this.links, required this.totalPages});

  factory SitemapResult.fromJson(Map<String, dynamic> json) {
    final links = List<String>.from(json['links'] ?? []);
    return SitemapResult(
      links: links,
      totalPages: links.length,
    );
  }
}

class CrawlStatus {
  final String status;
  final int total;
  final int completed;
  final List<ScrapedPage> data;
  final String? error;

  CrawlStatus({
    required this.status,
    required this.total,
    required this.completed,
    required this.data,
    this.error,
  });

  double get progress => total > 0 ? completed / total : 0;
  bool get isComplete => status == 'completed';
  bool get isFailed => status == 'failed';

  factory CrawlStatus.fromJson(Map<String, dynamic> json) {
    return CrawlStatus(
      status: json['status'] ?? 'unknown',
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      data: (json['data'] as List?)
          ?.map((e) => ScrapedPage.fromJson(e))
          .toList() ?? [],
      error: json['error'],
    );
  }
}

class ScrapedPage {
  final String url;
  final String? title;
  final String? markdown;
  final String? html;
  final Map<String, dynamic> metadata;

  ScrapedPage({
    required this.url,
    this.title,
    this.markdown,
    this.html,
    this.metadata = const {},
  });

  factory ScrapedPage.fromJson(Map<String, dynamic> json) {
    return ScrapedPage(
      url: json['url'] ?? json['sourceURL'] ?? '',
      title: json['metadata']?['title'] ?? json['title'] ?? 'Untitled',
      markdown: json['markdown'] as String?,
      html: json['html'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class FirecrawlException implements Exception {
  final String message;
  FirecrawlException(this.message);

  @override
  String toString() => 'FirecrawlException: $message';
}
