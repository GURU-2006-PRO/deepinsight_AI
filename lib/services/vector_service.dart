import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/page_model.dart';
import '../models/rag_models.dart';
import 'gemini_service.dart';

class VectorService {
  final GeminiService _gemini;
  late Box<ChunkModel> _chunksBox;
  bool _isInitialized = false;

  VectorService(this._gemini);

  Future<void> initialize() async {
    if (_isInitialized) return;
    _chunksBox = await Hive.openBox<ChunkModel>('chunks_box');
    _isInitialized = true;
  }

  /// Fulfills Requirement: "Automatically crawl and index relevant web pages"
  /// Optimized with Batching and Progress reporting
  Future<void> indexPages(
    String websiteId, 
    List<PageModel> pages, 
    {Function(double progress)? onProgress}
  ) async {
    await initialize();
    
    int totalChunksCount = 0;
    final Map<PageModel, List<ChunkModel>> pageToChunks = {};

    // 1. Pre-calculate all chunks
    for (final page in pages) {
      final chunks = _createChunks(websiteId, page);
      pageToChunks[page] = chunks;
      totalChunksCount += chunks.length;
    }

    if (totalChunksCount == 0) return;
    
    print('📦 [LOCAL] Indexing $totalChunksCount fragments across ${pages.length} pages...');
    
    int processedChunks = 0;
    const int batchSize = 10; // Gemini supports up to 100, but let's keep it safe for local RAM

    for (final entry in pageToChunks.entries) {
      final chunks = entry.value;
      
      for (int i = 0; i < chunks.length; i += batchSize) {
        final end = (i + batchSize < chunks.length) ? i + batchSize : chunks.length;
        final batch = chunks.sublist(i, end);
        final batchTexts = batch.map((c) => c.text).toList();

        try {
          // Requirement: Generate vector embeddings (Now in BATCH for speed)
          final embeddings = await _gemini.batchEmbedContents(batchTexts);
          
          final Map<String, ChunkModel> toPut = {};
          for (int j = 0; j < batch.length; j++) {
            final chunkWithVector = batch[j].copyWith(
              embedding: embeddings[j],
            );
            toPut[chunkWithVector.id] = chunkWithVector;
          }
          
          await _chunksBox.putAll(toPut);
          
          processedChunks += batch.length;
          if (onProgress != null) {
            onProgress(processedChunks / totalChunksCount);
          }
          
          print('⚡ Indexed $processedChunks/$totalChunksCount fragments...');
        } catch (e) {
          print('⚠️ Batch embedding failed: $e');
        }
      }
    }
    
    print('✅ Local Semantic Indexing complete.');
  }

  /// Fulfills Requirement: "Implement a RAG pipeline combining retrieval"
  Future<List<RetrievedChunk>> search(String websiteId, String query, {int topK = 5}) async {
    await initialize();
    
    print('🔍 [SEMANTIC] Generating query vector for: "$query"');
    
    try {
      final queryVector = await _gemini.getEmbedding(query);
      final results = <_VectorMatch>[];

      for (var chunk in _chunksBox.values) {
        if (chunk.websiteId != websiteId || chunk.embedding == null) continue;

        final similarity = _calculateCosineSimilarity(queryVector, chunk.embedding!);
        
        if (similarity > 0.35) { // Lowered threshold slightly for better recall
          results.add(_VectorMatch(chunk: chunk, score: similarity));
        }
      }

      results.sort((a, b) => b.score.compareTo(a.score));
      
      return results.take(topK).map((r) => RetrievedChunk(
        id: r.chunk.id,
        text: r.chunk.text,
        pageId: r.chunk.pageId,
        pageTitle: r.chunk.pageTitle,
        pageUrl: r.chunk.pageUrl,
        relevanceScore: r.score,
      )).toList();
    } catch (e) {
      print('❌ Search failed: $e');
      return [];
    }
  }

  List<ChunkModel> _createChunks(String websiteId, PageModel page) {
    final List<ChunkModel> chunks = [];
    final text = page.content;
    const int size = 800; // Optimal for RAG
    const int overlap = 150;
    int start = 0;
    int index = 0;

    while (start < text.length) {
      int end = start + size;
      if (end > text.length) end = text.length;

      final chunkText = text.substring(start, end).trim();
      if (chunkText.length > 30) {
        chunks.add(ChunkModel(
          id: const Uuid().v4(),
          pageId: page.id,
          websiteId: websiteId,
          text: chunkText,
          pageTitle: page.title,
          pageUrl: page.url,
          position: index++,
        ));
      }
      
      if (end >= text.length) break;
      start = end - overlap;
    }
    return chunks;
  }

  double _calculateCosineSimilarity(List<double> v1, List<double> v2) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    for (int i = 0; i < v1.length; i++) {
        dotProduct += v1[i] * v2[i];
        normA += v1[i] * v1[i];
        normB += v2[i] * v2[i];
    }
    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  int getChunkCount(String websiteId) {
    if (!_isInitialized) return 0;
    return _chunksBox.values.where((c) => c.websiteId == websiteId).length;
  }

  Future<void> clearWebsite(String websiteId) async {
    await initialize();
    final keysToDelete = _chunksBox.keys.where((k) {
      final val = _chunksBox.get(k);
      return val != null && val.websiteId == websiteId;
    }).toList();
    await _chunksBox.deleteAll(keysToDelete);
    print('🗑️ Cleared $websiteId from vector index.');
  }
}

class _VectorMatch {
  final ChunkModel chunk;
  final double score;
  _VectorMatch({required this.chunk, required this.score});
}
