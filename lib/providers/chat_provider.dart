import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/page_model.dart';
import '../models/website_model.dart';
import '../models/message_model.dart';
import '../models/rag_models.dart';
import '../services/jina_service.dart';
import '../services/vector_service.dart';
import '../services/rag_service.dart';

enum CrawlState { idle, crawling, mapping, indexing, complete, error }

class ChatProvider with ChangeNotifier {
  final JinaService _jina;
  final VectorService _vector;
  final RagService _rag;

  late Box<WebsiteModel> _websitesBox;
  late Box<PageModel> _pagesBox;
  late Box<MessageModel> _messagesBox;

  WebsiteModel? _currentWebsite;
  List<MessageModel> _messages = [];
  CrawlState _crawlState = CrawlState.idle;
  double _crawlProgress = 0;
  int _crawlCount = 0;
  String? _error;

  double _lastHallucinationRisk = 0;
  int _lastVerifiedClaims = 0;
  int _lastTotalClaims = 0;

  // Proactive Intelligence results
  String? _executiveSummary;
  Map<String, String> _keyInsights = {};
  List<String> _suggestions = [];

  ChatProvider(this._jina, this._vector, this._rag) {
    _init();
  }

  Future<void> _init() async {
    try {
      _websitesBox = await Hive.openBox<WebsiteModel>('websites_box');
      _pagesBox = await Hive.openBox<PageModel>('pages_box');
      _messagesBox = await Hive.openBox<MessageModel>('messages_box');
    } catch (e) {
      print('⚠️ Hive initialization error (likely schema change): $e');
      print('🔄 Clearing old data and reinitializing...');
      
      // Delete old boxes
      await Hive.deleteBoxFromDisk('websites_box');
      await Hive.deleteBoxFromDisk('pages_box');
      await Hive.deleteBoxFromDisk('messages_box');
      
      // Reopen fresh boxes
      _websitesBox = await Hive.openBox<WebsiteModel>('websites_box');
      _pagesBox = await Hive.openBox<PageModel>('pages_box');
      _messagesBox = await Hive.openBox<MessageModel>('messages_box');
      
      print('✅ Hive reinitialized successfully');
    }
    notifyListeners();
  }

  // Getters
  WebsiteModel? get currentWebsite => _currentWebsite;
  List<MessageModel> get messages => _messages;
  CrawlState get crawlState => _crawlState;
  double get crawlProgress => _crawlProgress;
  int get crawlCount => _crawlCount;
  String? get error => _error;
  double get lastHallucinationRisk => _lastHallucinationRisk;
  int get lastVerifiedClaims => _lastVerifiedClaims;
  int get lastTotalClaims => _lastTotalClaims;

  List<WebsiteModel> get allWebsites => _websitesBox.values.toList()
    ..sort((a, b) => b.crawledAt.compareTo(a.crawledAt));

  String? get executiveSummary => _executiveSummary;
  Map<String, String> get keyInsights => _keyInsights;
  List<String> get suggestions => _suggestions;
  RagService get ragService => _rag;

  Future<void> crawlWebsite(String url, {int maxPages = 20, String? researchGoal}) async {
    _error = null;
    _crawlProgress = 0;
    _crawlCount = 0;
    _crawlState = CrawlState.crawling;
    _executiveSummary = null;
    _keyInsights = {};
    _suggestions = [];
    notifyListeners();

    final websiteId = const Uuid().v4();
    final List<PageModel> crawledPages = [];
    String? firstTitle;

    try {
      // 1. Phased Crawling
      await _jina.crawlWebsite(
        url,
        maxPages: maxPages,
        onPageFound: (jinaPage) async {
          if (jinaPage.markdown == null || jinaPage.markdown!.trim().isEmpty) return;
          
          // Smart Capture: Check relevance if researchGoal is provided
          if (researchGoal != null && researchGoal.isNotEmpty) {
            print('🧠 [SMART] Checking relevance for: ${jinaPage.title}');
            final isRelevant = await _rag.geminiService.checkRelevance(
              content: jinaPage.markdown!,
              goal: researchGoal,
            );
            
            if (!isRelevant) {
              print('🗑️ [SMART] Skipping irrelevant page: ${jinaPage.title}');
              return;
            }
            print('✅ [SMART] Relevant page found: ${jinaPage.title}');
          }

          final pageModel = PageModel(
            id: const Uuid().v4(),
            websiteId: websiteId,
            url: jinaPage.url,
            title: jinaPage.title,
            content: jinaPage.markdown!,
            chunks: [],
            metadata: jinaPage.metadata,
            crawledAt: DateTime.now(),
          );

          firstTitle ??= jinaPage.title;
          await _pagesBox.put(pageModel.id, pageModel);
          crawledPages.add(pageModel);
        },
        onProgress: (current, total) {
          _crawlCount = current;
          _crawlProgress = (current / total) * 0.5; // Crawling is 50% of the work
          notifyListeners();
        },
      );

      if (crawledPages.isEmpty) {
        throw Exception('No content extracted from this website.');
      }

      // 2. Semantic Indexing Phase
      _crawlState = CrawlState.indexing;
      notifyListeners();

      await _vector.indexPages(
        websiteId, 
        crawledPages,
        onProgress: (indexingProgress) {
          _crawlProgress = 0.5 + (indexingProgress * 0.5); // Indexing is the other 50%
          notifyListeners();
        },
      );

      final website = WebsiteModel(
        id: websiteId,
        url: url,
        title: firstTitle ?? url,
        pageCount: _crawlCount,
        crawledAt: DateTime.now(),
        isComplete: true,
        totalChunks: _vector.getChunkCount(websiteId),
      );

      await _websitesBox.put(websiteId, website);
      _currentWebsite = website;
      _messages = [];
      _crawlState = CrawlState.complete;

      // Trigger Proactive Intelligence
      _generateProactiveInsights(crawledPages.take(5).toList());
      
      notifyListeners();

    } catch (e) {
      print('❌ Crawl Error: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _crawlState = CrawlState.error;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentWebsite == null || content.trim().isEmpty) return;

    final userMessage = MessageModel(
      id: const Uuid().v4(),
      websiteId: _currentWebsite!.id,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    await _messagesBox.put(userMessage.id, userMessage);

    final loadingMessage = MessageModel(
      id: const Uuid().v4(),
      websiteId: _currentWebsite!.id,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    
    _messages.add(loadingMessage);
    notifyListeners();

    try {
      final history = _messages
          .where((m) => !m.isLoading && m != userMessage && m.sources.isEmpty)
          .map((m) => m.isUser ? Content.text(m.content) : Content.model([TextPart(m.content)]))
          .toList();

      // Use Local RAG Pipeline via RagService
      final ragResponse = await _rag.processQuery(
        websiteId: _currentWebsite!.id,
        question: content,
        history: history.isNotEmpty ? history : null,
      );

      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }
      
      final botMessage = MessageModel(
        id: const Uuid().v4(),
        websiteId: _currentWebsite!.id,
        content: ragResponse.answer,
        isUser: false,
        timestamp: DateTime.now(),
        sources: ragResponse.sources.map((s) => SourceReference(
          pageId: '',
          pageTitle: s.pageTitle,
          pageUrl: s.pageUrl,
          excerpt: s.excerpt,
          relevanceScore: s.relevanceScore,
        )).toList(),
        confidence: ragResponse.confidence,
        noInfoFound: ragResponse.noInfoFound,
      );

      _messages.add(botMessage);
      await _messagesBox.put(botMessage.id, botMessage);
    } catch (e) {
      if (_messages.isNotEmpty && _messages.last.isLoading) {
        _messages.removeLast();
      }
      final errorMessage = MessageModel(
        id: const Uuid().v4(),
        websiteId: _currentWebsite!.id,
        content: "DeepInsight AI encountered an issue: ${e.toString()}",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    }
    notifyListeners();
  }

  Future<void> clearWebsite(String websiteId) async {
    await _vector.clearWebsite(websiteId);
    await _websitesBox.delete(websiteId);
    if (_currentWebsite?.id == websiteId) {
      _currentWebsite = null;
      _messages = [];
    }
    notifyListeners();
  }

  void loadWebsite(WebsiteModel website) {
    _currentWebsite = website;
    _messages = _messagesBox.values
        .where((m) => m.websiteId == website.id)
        .toList();
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _crawlState = CrawlState.complete;
    
    // Clear old insights when loading a new site
    _executiveSummary = "Exploring ${website.title}...";
    _keyInsights = {};
    _suggestions = [];
    
    notifyListeners();
  }

  Future<void> deleteWebsite() async {
    if (_currentWebsite == null) return;
    final id = _currentWebsite!.id;
    await clearWebsite(id);
  }

  void clearChat() {
    _messages = [];
    notifyListeners();
  }

  void startNewChat() {
    _currentWebsite = null;
    _messages = [];
    _crawlState = CrawlState.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> _generateProactiveInsights(List<PageModel> pages) async {
    if (pages.isEmpty) return;

    try {
      final combinedContext = pages.map((p) => p.content).join('\n\n').substring(0, 4000);
      final intelligence = await _rag.geminiService.generateIntelligence(
        _currentWebsite?.title ?? 'Website',
        combinedContext,
      );

      _executiveSummary = intelligence['summary'];
      _keyInsights = Map<String, String>.from(intelligence['insights'] ?? {});
      _suggestions = List<String>.from(intelligence['questions'] ?? []);
      notifyListeners();
    } catch (e) {
      print('Proactive Intelligence Error: $e');
    }
  }
}
