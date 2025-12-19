import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'dart:async';

/// Jina AI Reader - FREE alternative to Firecrawl
/// Supports Parallel Crawling with Smart Retry logic
class JinaService {
  static const String _readerUrl = 'https://r.jina.ai';
  final String? apiKey;

  JinaService({this.apiKey});

  /// Scrape a single page using Jina Reader
  Future<JinaPage> scrapePage(String url, {bool verbose = false}) async {
    try {
      final requestUrl = '$_readerUrl/${Uri.encodeFull(url)}';
      
      final headers = {
        'Accept': 'text/plain',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      };

      if (apiKey != null && apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }
      
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final content = response.body;
        String title = _extractDomain(url);
        final lines = content.split('\n');
        for (final line in lines.take(5)) {
          if (line.startsWith('Title:')) {
            title = line.substring(6).trim();
            break;
          }
          if (line.startsWith('# ')) {
            title = line.substring(2).trim();
            break;
          }
        }
        
        return JinaPage(
          url: url,
          title: title,
          markdown: content,
          metadata: {},
        );
      } else if (response.statusCode == 429) {
        throw JinaException('429');
      } else {
        // FALLBACK: Try direct fetch if Jina is blocked (403/451)
        print('⚠️ Jina failed (${response.statusCode}), trying direct fetch for $url');
        final fallbackResponse = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': headers['User-Agent']!},
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode == 200) {
          final document = html_parser.parse(fallbackResponse.body);
          
          // Remove genuinely intrusive elements
          document.querySelectorAll('script, style, noscript, iframe, head').forEach((el) => el.remove());
          
          // Try to find the "Meat" of the page
          final body = document.querySelector('main, article, #content, .content') ?? document.body;
          
          if (body != null) {
            final buffer = StringBuffer();
            
            // Extract text with structure preservation
            void processNode(dom.Node node) {
              if (node is dom.Element) {
                final tag = node.localName;
                
                // Add structure based on tags
                if (RegExp(r'^h[1-6]$').hasMatch(tag!)) buffer.write('\n\n# ');
                if (tag == 'p' || tag == 'div' || tag == 'section') buffer.write('\n\n');
                if (tag == 'li') buffer.write('\n- ');
                
                for (var child in node.nodes) {
                  processNode(child);
                }
                
                if (tag == 'p' || tag == 'div' || tag == 'section' || RegExp(r'^h[1-6]$').hasMatch(tag)) {
                  buffer.write('\n');
                }
              } else if (node.nodeType == dom.Node.TEXT_NODE) {
                final text = node.text?.trim() ?? '';
                if (text.isNotEmpty) {
                  buffer.write('$text ');
                }
              }
            }
            
            processNode(body);
            
            final richText = buffer.toString()
                .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Clean up excessive newlines
                .trim();

            return JinaPage(
              url: url,
              title: _extractDomain(url),
              markdown: richText,
              metadata: {'method': 'direct_fallback_smart_extract'},
            );
          }
        }
        
        throw JinaException('Failed to scrape: ${response.statusCode}');
      }
    } catch (e) {
      if (e is JinaException) rethrow;
      throw JinaException('Network error: $e');
    }
  }

  /// Discover same-domain links
  Future<List<String>> discoverLinks(String baseUrl, {String? allowedHost}) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (compatible; RAGChatbot/1.0)'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) return [];

      final document = html_parser.parse(response.body);
      final links = <String>{};
      final baseUri = Uri.parse(baseUrl);
      final targetHost = allowedHost ?? baseUri.host;

      for (final element in document.querySelectorAll('a[href]')) {
        final href = element.attributes['href'];
        if (href == null || href.isEmpty) continue;

        try {
          final uri = Uri.parse(href);
          final absoluteUrl = uri.hasScheme ? href : baseUri.resolve(href).toString();
          final linkUri = Uri.parse(absoluteUrl);

          if (linkUri.host == targetHost) {
            if (!absoluteUrl.contains('#') && !_isBinaryFile(absoluteUrl)) {
              links.add(absoluteUrl);
            }
          }
        } catch (_) {}
      }
      return links.toList();
    } catch (e) {
      return [];
    }
  }

  bool _isBinaryFile(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.pdf') || lower.endsWith('.jpg') || lower.endsWith('.png') ||
           lower.endsWith('.gif') || lower.endsWith('.css') || lower.endsWith('.js') ||
           lower.endsWith('.zip') || lower.endsWith('.exe');
  }

  /// Optimized Crawl that processes pages on-the-fly to save memory.
  /// No longer returns a giant list, but uses a callback for each page.
  Future<void> crawlWebsite(
    String startUrl, {
    int maxPages = 50,
    int concurrency = 2, // Further reduced for stability
    required Future<void> Function(JinaPage page) onPageFound,
    Function(int current, int total)? onProgress,
  }) async {
    final visited = <String>{};
    final toVisit = <String>[_normalizeUrl(startUrl)];
    int processedCount = 0;
    int retryWaitSeconds = 2;

    print('\n${"=" * 70}');
    print('🚀 STARTING MEMORY-SAFE CRAWL');
    print('URL: $startUrl');
    print('${"=" * 70}\n');

    String? canonicalHost;

    while (toVisit.isNotEmpty && processedCount < maxPages) {
      final batch = <String>[];
      while (toVisit.isNotEmpty && batch.length < concurrency && (processedCount + batch.length) < maxPages) {
        final url = toVisit.removeAt(0);
        final norm = _normalizeUrl(url);
        if (!visited.contains(norm)) {
          visited.add(norm);
          batch.add(url);
        }
      }

      if (batch.isEmpty) break;

      // Process batch with slight delay between each to avoid Jina 401/rate limits
      final results = await Future.wait(batch.map((url) async {
        try {
          // Staggered delay within the batch
          await Future.delayed(Duration(milliseconds: batch.indexOf(url) * 800 + 200));
          
          final page = await scrapePage(url);
          
          if (page.markdown != null && page.markdown!.length > 50) {
            if (canonicalHost == null) {
              try {
                canonicalHost = Uri.parse(url).host;
                print('📍 Canonical host set to: $canonicalHost');
              } catch (_) {}
            }
            
            final links = await discoverLinks(url, allowedHost: canonicalHost);
            return {'page': page, 'links': links, 'status': 'ok'};
          }
        } catch (e) {
          if (e.toString().contains('429')) {
             return {'url': url, 'status': 'retry'};
          }
          print('[FAIL] $url - $e');
        }
        return null;
      }));

      bool needsBackoff = false;

      for (final result in results) {
        if (result == null) continue;
        
        if (result['status'] == 'retry') {
          final url = result['url'] as String;
          toVisit.add(url); 
          visited.remove(_normalizeUrl(url));
          needsBackoff = true;
        } else if (result['status'] == 'ok') {
          final page = result['page'] as JinaPage;
          final links = result['links'] as List<String>;
          
          processedCount++;
          
          // CRITICAL: Process and clear page from memory immediately
          await onPageFound(page);
          
          print('[OK] [#$processedCount] ${page.title}');
          
          for (final link in links) {
            final norm = _normalizeUrl(link);
            if (!visited.contains(norm) && !toVisit.contains(norm)) {
              toVisit.add(norm);
            }
          }
          retryWaitSeconds = 2;
        }
      }

      if (needsBackoff) {
        print('⚠️ [RATE LIMIT] Slowing down... waiting $retryWaitSeconds seconds');
        await Future.delayed(Duration(seconds: retryWaitSeconds));
        retryWaitSeconds *= 2; 
        if (retryWaitSeconds > 30) retryWaitSeconds = 30;
      }

      onProgress?.call(processedCount, maxPages);
    }

    print('\n${"=" * 70}');
    print('⚡ CRAWL COMPLETE: $processedCount PAGES PROCESSED');
    print('${"=" * 70}\n');
  }
  
  String _normalizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      var path = uri.path;
      if (path.endsWith('/') && path.length > 1) {
        path = path.substring(0, path.length - 1);
      }
      return '${uri.scheme}://${uri.host}$path';
    } catch (_) {
      return url;
    }
  }

  String _extractDomain(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return 'Unknown';
    }
  }
}

class JinaPage {
  final String url;
  final String title;
  final String? markdown;
  final Map<String, dynamic> metadata;

  JinaPage({
    required this.url,
    required this.title,
    this.markdown,
    this.metadata = const {},
  });
}

class JinaException implements Exception {
  final String message;
  JinaException(this.message);

  @override
  String toString() => 'JinaException: $message';
}
