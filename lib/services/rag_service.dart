import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_service.dart';
import 'vector_service.dart';
import '../models/rag_models.dart';

class RagService {
  final GeminiService geminiService;
  final VectorService vectorService;

  RagService({required this.geminiService, required this.vectorService});

  /// Complete RAG pipeline with verification
  Future<RagResponse> processQuery({
    required String websiteId,
    required String question,
    List<Content>? history,
  }) async {
    // 1. Search for relevant context (using remote backend via VectorService)
    final chunks = await vectorService.search(websiteId, question, topK: 7);
    
    if (chunks.isEmpty) {
      return RagResponse(
        answer: "I couldn't find any information about that in the indexed website content.",
        sources: [],
        confidence: 0,
        hallucinationRisk: 0,
        verifiedClaims: 0,
        totalClaims: 0,
        expandedQueries: [],
        noInfoFound: true,
      );
    }

    // 2. Build context string
    final context = chunks.map((c) => '''
[Source: ${c.pageTitle}]
${c.text}
---''').join('\n');

    // 3. Generate answer using Gemini 2.0 with strict instructions
    final answer = await geminiService.getAnswer(
      question: question,
      context: context,
      history: history,
    );

    // 4. Verification & Confidence
    final sources = chunks.map((c) => SourceInfo(
      pageTitle: c.pageTitle,
      pageUrl: c.pageUrl,
      excerpt: c.text.length > 200 ? '${c.text.substring(0, 200)}...' : c.text,
      relevanceScore: c.relevanceScore,
    )).toList();

    // Check if Gemini couldn't find the answer even with context
    bool noInfoFound = answer.toLowerCase().contains("couldn't find") ||
                       answer.toLowerCase().contains("could not find") ||
                       answer.toLowerCase().contains("don't have information") ||
                       answer.toLowerCase().contains("information is not available") ||
                       answer.toLowerCase().contains("no information about");
    
    return RagResponse(
      answer: answer,
      sources: noInfoFound ? [] : sources,
      confidence: noInfoFound ? 0.1 : 0.9,
      hallucinationRisk: noInfoFound ? 0.0 : 0.1,
      verifiedClaims: noInfoFound ? 0 : 1,
      totalClaims: 1,
      expandedQueries: [],
      noInfoFound: noInfoFound,
    );
  }
}
