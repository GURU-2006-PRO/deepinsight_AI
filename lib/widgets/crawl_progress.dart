import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/chat_provider.dart';

class CrawlProgressView extends StatelessWidget {
  final CrawlState state;
  final double progress;
  final int crawlCount;

  const CrawlProgressView({
    super.key,
    required this.state,
    required this.progress,
    required this.crawlCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProcessing = state == CrawlState.crawling || state == CrawlState.indexing;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(theme),
            const SizedBox(height: 32),
            Text(
              _getTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isProcessing) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null, 
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state == CrawlState.crawling ? Icons.file_download_outlined : Icons.auto_awesome_motion_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state == CrawlState.crawling 
                        ? '$crawlCount pages found'
                        : 'Indexing Semantic Fragments...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 12, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData icon;
    switch (state) {
      case CrawlState.mapping:
        icon = Icons.hub_outlined;
        break;
      case CrawlState.crawling:
        icon = Icons.cloud_download_outlined;
        break;
      case CrawlState.indexing:
        icon = Icons.memory_rounded;
        break;
      default:
        icon = Icons.hourglass_empty;
    }

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.primary,
      highlightColor: theme.colorScheme.primaryContainer,
      child: Icon(icon, size: 80),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms);
  }

  String _getTitle() {
    switch (state) {
      case CrawlState.mapping:
        return 'Mapping Website';
      case CrawlState.crawling:
        return 'Crawling Pages';
      case CrawlState.indexing:
        return 'Building Intelligence';
      default:
        return 'Processing...';
    }
  }

  String _getSubtitle() {
    switch (state) {
      case CrawlState.mapping:
        return 'Discovering pages and structure...';
      case CrawlState.crawling:
        return 'Downloading and extracting content...';
      case CrawlState.indexing:
        return 'Generating semantic vectors for your chat...';
      default:
        return 'Please wait while we prepare your data...';
    }
  }
}
