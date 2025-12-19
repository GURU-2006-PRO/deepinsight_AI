import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_view.dart';
import '../widgets/url_input_view.dart';
import '../widgets/crawl_progress.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: Text(
            provider.currentWebsite?.title ?? 'DeepInsight AI',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0D0D0D),
                      const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                    ]
                  : [
                      Colors.white,
                      Colors.blue.shade50.withValues(alpha: 0.3),
                    ],
            ),
          ),
        ),
        actions: [
          if (provider.currentWebsite != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => provider.startNewChat(),
                tooltip: 'New Chat',
              ),
            ),
        ],
      ),
      drawer: _buildHistorySidebar(context, provider),
      body: SafeArea(
        child: _buildContent(context, provider),
      ),
    );
  }

  Widget _buildHistorySidebar(BuildContext context, ChatProvider provider) {
    final theme = Theme.of(context);
    final websites = provider.allWebsites;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark 
          ? const Color(0xFF171717) 
          : Colors.grey[50],
      child: Column(
        children: [
          // Header with Gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DeepInsight AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semantic Research Assistant',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // New Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: InkWell(
              onTap: () {
                provider.startNewChat();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'New Research Chat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // History Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Recent Research',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Sidear History List
          Expanded(
            child: websites.isEmpty
                ? const Center(
                    child: Text('No previous chats yet', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: websites.length,
                    itemBuilder: (context, index) {
                      final site = websites[index];
                      final isSelected = provider.currentWebsite?.id == site.id;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          onTap: () {
                            provider.loadWebsite(site);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          selected: isSelected,
                          selectedTileColor: theme.brightness == Brightness.dark 
                              ? Colors.white.withValues(alpha: 0.1) 
                              : theme.colorScheme.primary.withValues(alpha: 0.1),
                          leading: Icon(
                            Icons.article_outlined,
                            size: 18,
                            color: isSelected ? theme.colorScheme.primary : Colors.grey,
                          ),
                          title: Text(
                            site.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : null,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, h:mm a').format(site.crawledAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle, size: 14)
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  onPressed: () => provider.clearWebsite(site.id),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          
          const Divider(height: 1),
          
          // User Info / Settings area
          ListTile(
            leading: const CircleAvatar(
              radius: 14,
              child: Text('D', style: TextStyle(fontSize: 12)),
            ),
            title: const Text('DeepInsight AI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Local Semantic Search', style: TextStyle(fontSize: 10)),
            trailing: const Icon(Icons.settings_outlined, size: 18),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChatProvider provider) {
    switch (provider.crawlState) {
      case CrawlState.idle:
        return const UrlInputView();
      case CrawlState.mapping:
      case CrawlState.crawling:
      case CrawlState.indexing:
        return CrawlProgressView(
          state: provider.crawlState,
          progress: provider.crawlProgress,
          crawlCount: provider.crawlCount,
        );
      case CrawlState.complete:
        return const ChatView();
      case CrawlState.error:
        return _buildErrorView(context, provider);
    }
  }

  Widget _buildErrorView(BuildContext context, ChatProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('System Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Connection lost while crawling.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.startNewChat(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
