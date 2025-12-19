class RetrievedChunk {
  final String id;
  final String text;
  final String pageId;
  final String pageTitle;
  final String pageUrl;
  final double relevanceScore;

  RetrievedChunk({
    required this.id,
    required this.text,
    required this.pageId,
    required this.pageTitle,
    required this.pageUrl,
    required this.relevanceScore,
  });
}

class SourceInfo {
  final String pageTitle;
  final String pageUrl;
  final String excerpt;
  final double relevanceScore;

  SourceInfo({
    required this.pageTitle,
    required this.pageUrl,
    required this.excerpt,
    required this.relevanceScore,
  });
}

class RagResponse {
  final String answer;
  final List<SourceInfo> sources;
  final double confidence;
  final double hallucinationRisk;
  final int verifiedClaims;
  final int totalClaims;
  final List<String> expandedQueries;
  final bool noInfoFound; // Flag for when no information is found

  RagResponse({
    required this.answer,
    required this.sources,
    required this.confidence,
    required this.hallucinationRisk,
    required this.verifiedClaims,
    required this.totalClaims,
    required this.expandedQueries,
    this.noInfoFound = false,
  });

  String get confidenceLabel {
    if (confidence >= 0.8) return 'HIGH';
    if (confidence >= 0.5) return 'MEDIUM';
    return 'LOW';
  }

  String get riskLabel {
    if (hallucinationRisk <= 0.2) return 'SAFE';
    if (hallucinationRisk <= 0.4) return 'CAUTION';
    return 'UNRELIABLE';
  }
}
