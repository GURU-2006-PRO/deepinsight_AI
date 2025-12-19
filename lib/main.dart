import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/message_model.dart';
import 'models/page_model.dart';
import 'models/website_model.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';
import 'services/vector_service.dart';
import 'services/jina_service.dart';
import 'services/gemini_service.dart';
import 'services/rag_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(WebsiteModelAdapter());
  Hive.registerAdapter(PageModelAdapter());
  Hive.registerAdapter(ChunkModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(SourceReferenceAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Service Instantiation
    final jina = JinaService(apiKey: dotenv.env['JINA_API_KEY'] ?? '');
    final gemini = GeminiService(apiKey: dotenv.env['GEMINI_API_KEY'] ?? '');
    final vector = VectorService(gemini);
    final rag = RagService(geminiService: gemini, vectorService: vector);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(jina, vector, rag),
        ),
      ],
      child: MaterialApp(
        title: 'DeepInsight AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6),
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.outfitTextTheme(),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[50],
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            primary: const Color(0xFF818CF8),
            secondary: const Color(0xFFA5B4FC),
            surface: const Color(0xFF0F172A),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          scaffoldBackgroundColor: const Color(0xFF020617),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1E293B),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
