import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class GeminiService {
  final GenerativeModel _model;
  final GenerativeModel _embeddingModel;

  GeminiService({required String apiKey}) 
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      ),
      _embeddingModel = GenerativeModel(
        model: 'text-embedding-004',
        apiKey: apiKey,
      );

  Future<String> getAnswer({
    required String question,
    required String context,
    List<Content>? history,
  }) async {
    final prompt = [
      if (history != null) ...history,
      Content.text('''### SYSTEM ROLE
You are DeepInsight AI, a high-fidelity RAG analyzer. Your goal is to provide accurate answers based EXCLUSIVELY on the website context provided below.

### WEBSITE CONTEXT:
$context

### OPERATIONAL GUIDELINES:
1. **Source Grounding**: Answer using the context. Cite sources like [Source: Page Title].
2. **Handle Gaps**: If the context doesn't contain the answer, say "I couldn't find specific details on that in the crawled content of this site."
3. **Tone**: Be helpful, insightful, and concise.

### USER REQUEST:
$question

### YOUR RESPONSE (as DeepInsight AI):'''),
    ];

    print('🤖 [AI] Requesting answer from Gemini...');
    final response = await _model.generateContent(prompt);
    
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      return 'DeepInsight AI was unable to generate a specific answer for this query based on the current context.';
    }
    
    return text;
  }

  Future<List<double>> getEmbedding(String text) async {
    final result = await _embeddingModel.embedContent(Content.text(text));
    return result.embedding.values.toList();
  }

  Future<List<List<double>>> batchEmbedContents(List<String> texts) async {
    final requests = texts.map((t) => EmbedContentRequest(Content.text(t))).toList();
    final result = await _embeddingModel.batchEmbedContents(requests);
    return result.embeddings.map((e) => e.values.toList()).toList();
  }

  Future<Map<String, dynamic>> generateIntelligence(String title, String context) async {
     final prompt = [
      Content.text('''### TASK
As an AI Web Analyst, perform a deep analysis of the following website content for "$title".

### CONTENT TO ANALYZE:
$context

### OUTPUT REQUIREMENTS
Return a strict JSON object with exactly these fields:
1. "summary": A sophisticated, professional 2-sentence executive summary that captures the core mission and primary value proposition.
2. "insights": A dictionary/map of exactly 4 critical business facts (e.g., "Core Service", "Target Audience", "Key Benefit", "Contact/Pricing").
3. "questions": 3 highly relevant, curiosity-driven questions that would help a user discover the most valuable features of this specific site.

### FORMAT
Raw JSON only. No markdown formatting, no code blocks, no preamble. Just the JSON object.''')
    ];

    final response = await _model.generateContent(prompt);
    try {
      final String text = response.text ?? '{}';
      // Basic cleanup if model adds markdown
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleanText);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {
        'summary': 'Summary not available.',
        'insights': {},
        'questions': ['What can this site do?', 'Tell me more', 'How do I start?']
      };
    }
  }

  /// Search the web using Gemini (fallback when no indexed content found)
  Future<String> searchWeb(String question) async {
    print('🌐 [Web Search] Answering question: $question');
    
    final prompt = '''You are DeepInsight AI. The user asked a question that couldn't be answered from the indexed website content.

Please provide a COMPREHENSIVE and DETAILED answer to this question using your general knowledge:

Question: $question

IMPORTANT INSTRUCTIONS:
1. Provide a thorough, well-explained answer with all relevant details
2. Include specific facts, data, and explanations
3. Structure your answer clearly with paragraphs if needed
4. At the end, include 2-3 relevant source links where users can verify or learn more
5. Format sources as clickable markdown links like this: [Source Name](https://url.com)
6. Make sure the answer is complete and informative, as if the user searched on Google

Your detailed response:''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate an answer at this time.';
    } catch (e) {
      print('❌ Answer generation error: $e');
      return 'I encountered an error while trying to answer your question. Error: ${e.toString()}';
    }
  }

  /// Check if content is relevant to a research goal (for Smart Capture)
  Future<bool> checkRelevance({required String content, required String goal}) async {
    final prompt = '''### TASK
Evaluate if the following website content is relevant to the Research Goal.

### RESEARCH GOAL:
$goal

### CONTENT PREVIEW:
${content.length > 3000 ? content.substring(0, 3000) : content}

### OUTPUT REQUIREMENT
Return only 'YES' or 'NO'. No explanation. If the content is broadly related or helpful for the goal, return 'YES'. If it's completely irrelevant (legal pages, login screens, unrelated ads), return 'NO'.''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim().toUpperCase() ?? '';
      return text.contains('YES');
    } catch (e) {
      print('⚠️ Relevance check failed: $e');
      return true; // Default to true to be safe
    }
  }
}
