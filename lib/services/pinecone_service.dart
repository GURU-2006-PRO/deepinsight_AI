import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/rag_models.dart';

class PineconeService {
  late final String _apiKey;
  late final String _indexUrl;
  
  PineconeService() {
    _apiKey = dotenv.get('PINECONE_API_KEY', fallback: '');
    _indexUrl = dotenv.get('PINECONE_INDEX_URL', fallback: '');
  }

  bool get isReady => _apiKey.isNotEmpty && _indexUrl.isNotEmpty;

  /// Upsert vectors to Pinecone
  Future<void> upsert(String websiteId, List<RetrievedChunk> chunks, List<List<double>> embeddings) async {
    if (!isReady) throw Exception('Pinecone not configured in .env');

    final List<Map<String, dynamic>> vectors = [];
    for (int i = 0; i < chunks.length; i++) {
      vectors.add({
        'id': chunks[i].id,
        'values': embeddings[i],
        'metadata': {
          'websiteId': websiteId,
          'text': chunks[i].text,
          'pageTitle': chunks[i].pageTitle,
          'pageUrl': chunks[i].pageUrl,
        },
      });
    }

    final response = await http.post(
      Uri.parse('$_indexUrl/vectors/upsert'),
      headers: {
        'Api-Key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'vectors': vectors,
        'namespace': websiteId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Pinecone upsert failed: ${response.body}');
    }
  }

  /// Query vectors from Pinecone
  Future<List<RetrievedChunk>> query(String websiteId, List<double> queryVector, {int topK = 7}) async {
    if (!isReady) throw Exception('Pinecone not configured in .env');

    final response = await http.post(
      Uri.parse('$_indexUrl/query'),
      headers: {
        'Api-Key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'vector': queryVector,
        'topK': topK,
        'includeMetadata': true,
        'namespace': websiteId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Pinecone query failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final results = <RetrievedChunk>[];

    for (var match in data['matches'] ?? []) {
      final metadata = match['metadata'] ?? {};
      results.add(RetrievedChunk(
        id: match['id'],
        text: metadata['text'] ?? '',
        pageId: metadata['pageUrl'] ?? '',
        pageTitle: metadata['pageTitle'] ?? 'Unknown',
        pageUrl: metadata['pageUrl'] ?? '',
        relevanceScore: (match['score'] as num).toDouble(),
      ));
    }

    return results;
  }

  Future<void> deleteWebsite(String websiteId) async {
    if (!isReady) return;
    
    await http.post(
      Uri.parse('$_indexUrl/vectors/delete'),
      headers: {
        'Api-Key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'deleteAll': true,
        'namespace': websiteId,
      }),
    );
  }
}
