import 'dart:convert';
import 'package:http/http.dart' as http;

class EmbeddingService {
  final String apiKey;
  static const String _baseUrl = 'https://api.jina.ai/v1/embeddings';

  EmbeddingService({required this.apiKey});

  Future<List<List<double>>> getEmbeddings(List<String> texts) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'jina-embeddings-v2-base-en',
          'input': texts,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embeddings = (data['data'] as List)
            .map((item) => (item['embedding'] as List).map((v) => (v as num).toDouble()).toList())
            .toList();
        return embeddings;
      } else {
        throw Exception('Jina Embedding Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get embeddings: $e');
    }
  }
}
