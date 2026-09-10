// Data models representing structured section breakdown and overall resume analysis.

class SectionScore {
  final String name;
  final int score;
  final String feedback;

  const SectionScore({
    required this.name,
    required this.score,
    required this.feedback,
  });

  factory SectionScore.fromJson(Map<String, dynamic> json) {
    return SectionScore(
      name: json['name'] as String? ?? 'Section',
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? 'No feedback provided.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'feedback': feedback,
    };
  }
}

class ResumeAnalysis {
  final String id;
  final int overallScore;
  final int? matchPercent;
  final List<SectionScore> sections;
  final List<String> missingKeywords;
  final List<String> suggestions;
  final String? targetRole;
  final String? fileName;
  final DateTime createdAt;

  ResumeAnalysis({
    String? id,
    required this.overallScore,
    this.matchPercent,
    required this.sections,
    required this.missingKeywords,
    required this.suggestions,
    this.targetRole,
    this.fileName,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  /// Constructs [ResumeAnalysis] from LLM structured JSON response.
  /// Handles type safety and null checks gracefully to prevent crashes.
  factory ResumeAnalysis.fromJson(
    Map<String, dynamic> json, {
    String? targetRole,
    String? fileName,
  }) {
    // Parse sections safely
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    final sectionsList = rawSections
        .map((s) => SectionScore.fromJson(s as Map<String, dynamic>))
        .toList();

    // Parse missing keywords safely
    final rawKeywords = json['missingKeywords'] as List<dynamic>? ?? [];
    final keywordsList = rawKeywords.map((k) => k.toString()).toList();

    // Parse suggestions safely
    final rawSuggestions = json['suggestions'] as List<dynamic>? ?? [];
    final suggestionsList = rawSuggestions.map((s) => s.toString()).toList();

    return ResumeAnalysis(
      id: json['id'] as String?,
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      matchPercent: json['matchPercent'] != null
          ? (json['matchPercent'] as num).toInt()
          : null,
      sections: sectionsList,
      missingKeywords: keywordsList,
      suggestions: suggestionsList,
      targetRole: targetRole ?? (json['targetRole'] as String?),
      fileName: fileName ?? (json['fileName'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts model to Map for local storage (Hive) or serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overallScore': overallScore,
      'matchPercent': matchPercent,
      'sections': sections.map((s) => s.toJson()).toList(),
      'missingKeywords': missingKeywords,
      'suggestions': suggestions,
      'targetRole': targetRole,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
