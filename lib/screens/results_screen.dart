import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/resume_analysis.dart';
import '../providers/analysis_provider.dart';
import '../services/pdf_export_service.dart';
import '../widgets/score_gauge.dart';
import '../widgets/section_card.dart';
import '../widgets/suggestion_tile.dart';
import '../widgets/match_badge.dart';

/// Screen displaying complete structured analysis results.
class ResultsScreen extends StatelessWidget {
  final ResumeAnalysis? analysisOverride;

  const ResultsScreen({super.key, this.analysisOverride});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    final analysis = analysisOverride ?? provider.currentAnalysis;

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No analysis available.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Resume Scorecard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF Report',
            onPressed: () => PdfExportService.exportAnalysisPdf(analysis),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Gauge Section
            Center(
              child: ScoreGauge(score: analysis.overallScore),
            ),
            const SizedBox(height: 24),

            // Target Role Match Badge (if available)
            if (analysis.matchPercent != null && analysis.targetRole != null) ...[
              MatchBadge(
                matchPercent: analysis.matchPercent!,
                targetRole: analysis.targetRole!,
              ),
              const SizedBox(height: 24),
            ],

            // Section Breakdown Title
            const Text(
              'Section Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Section Score Cards
            ...analysis.sections.map((section) => SectionCard(section: section)),

            const SizedBox(height: 20),

            // Missing Keywords Section (if available)
            if (analysis.missingKeywords.isNotEmpty) ...[
              const Text(
                'Missing Keywords for Target Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.missingKeywords
                    .map(
                      (kw) => Chip(
                        avatar: const Icon(Icons.add_circle_outline, size: 16, color: Colors.deepOrange),
                        label: Text(kw),
                        backgroundColor: Colors.deepOrange.shade50,
                        side: BorderSide(color: Colors.deepOrange.shade200),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange.shade900,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Improvement Suggestions Section
            const Text(
              'Actionable Improvement Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...analysis.suggestions.asMap().entries.map(
                  (entry) => SuggestionTile(
                    suggestion: entry.value,
                    index: entry.key + 1,
                  ),
                ),

            const SizedBox(height: 32),

            // Bottom Action Buttons
            ElevatedButton.icon(
              onPressed: () => PdfExportService.exportAnalysisPdf(analysis),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export Report as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                provider.reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Analyze Another Resume'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
