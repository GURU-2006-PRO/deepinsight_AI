import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rag_models.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  final String apiKey;

  GroqService({required this.apiKey});
  
  String get apiKeyValue => apiKey;

  static const String _ragPromptTemplate = '''
### SYSTEM ROLE
You are an advanced AI Assistant specializing in Context-Aware RAG. You provide highly accurate answers derived SOLELY from the provided website context.

### CONTEXT:
{context}

### OPERATING PROTOCOL:
1. **Source Fidelity**: Use ONLY the information provided in the context above.
2. **Grounding**: If the answer cannot be found in the context, clearly state: "The requested information is not available in the provided website content."
3. **Professionalism**: Maintain a helpful, analytical, and professional tone.
4. **Citations**: Reference the specific [Source: Page Title] whenever possible to build trust.
5. **No Hallucinations**: Do not invent facts, dates, or details not found in the source text.

### USER QUERY:
{question}

### ANALYTICAL RESPONSE:''';

  Future<GroqResponse> generateResponse({
    required String question,
    required List<RetrievedChunk> chunks,
    double temperature = 0.3,
    int maxTokens = 1024,
  }) async {
    final context = chunks.map((c) => '''
[Source: ${c.pageTitle}]
${c.text}
---''').join('\n');

    final prompt = _ragPromptTemplate
        .replaceAll('{context}', context)
        .replaceAll('{question}', question);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
          'top_p': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ?? '';
        
        // Calculate confidence based on chunk relevance
        final avgRelevance = chunks.isEmpty 
            ? 0.0 
            : chunks.map((c) => c.relevanceScore).reduce((a, b) => a + b) / chunks.length;
        
        return GroqResponse(
          text: text,
          confidence: avgRelevance,
          usedChunks: chunks,
        );
      } else {
        throw GroqException('API error: ${response.body}');
      }
    } catch (e) {
      if (e is GroqException) rethrow;
      throw GroqException('Network error: $e');
    }
  }

  Future<List<String>> generateSuggestions(String websiteTitle, List<String> sampleContent) async {
    final prompt = '''
Based on this website "$websiteTitle" with content samples:
${sampleContent.take(3).join('\n')}

Generate 3 short, helpful questions a user might ask. Return only the questions, one per line.''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 256,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ?? '';
        return text.split('\n').where((s) => s.trim().isNotEmpty).take(3).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ProactiveIntelligence> generateProactiveIntelligence(String title, String context) async {
    final prompt = '''
### ANALYST ROLE
Perform a comprehensive business analysis of the website: "$title".

### SOURCE MATERIAL:
$context

### JSON SPECIFICATIONS
Generate a JSON object with strictly these keys:
- "summary": A professional 2-sentence summary of the site's purpose.
- "insights": A map of 4 key data points (e.g. Headquarters, Core Technology, Primary Audience, Unique Offering).
- "questions": 3 strategic questions for the user to explore the site's deeper value.

### OUTPUT FORMAT
Strict JSON only. No text before or after the JSON block.''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = jsonDecode(data['choices'][0]['message']['content']);
        
        return ProactiveIntelligence(
          summary: content['summary'] ?? '',
          insights: Map<String, String>.from(content['insights'] ?? {}),
          suggestions: List<String>.from(content['questions'] ?? []),
        );
      }
    } catch (e) {
      print('Error generating intelligence: $e');
    }
    
    return ProactiveIntelligence(
      summary: 'Analysis complete. You can now ask questions about this site.',
      insights: {},
      suggestions: ['Tell me more about this site', 'What are the main services?', 'How do I contact them?'],
    );
  }
}

class ProactiveIntelligence {
  final String summary;
  final Map<String, String> insights;
  final List<String> suggestions;

  ProactiveIntelligence({
    required this.summary,
    required this.insights,
    required this.suggestions,
  });
}

class GroqResponse {
  final String text;
  final double confidence;
  final List<RetrievedChunk> usedChunks;

  GroqResponse({
    required this.text,
    required this.confidence,
    required this.usedChunks,
  });
}

class GroqException implements Exception {
  final String message;
  GroqException(this.message);

  @override
  String toString() => 'GroqException: $message';
}
