import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/resume_analysis.dart';

/// Section Breakdown Card displaying individual scores and feedback for
/// Summary, Skills, Experience, Education, and Formatting.
class SectionCard extends StatelessWidget {
  final SectionScore section;

  const SectionCard({
    super.key,
    required this.section,
  });

  IconData _getSectionIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('summary')) return Icons.description_outlined;
    if (lower.contains('skill')) return Icons.psychology_outlined;
    if (lower.contains('experience') || lower.contains('work')) {
      return Icons.work_outline;
    }
    if (lower.contains('education')) return Icons.school_outlined;
    if (lower.contains('format')) return Icons.space_dashboard_outlined;
    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = AppColors.getScoreColor(section.score);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getSectionIcon(section.name),
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getScoreBgColor(section.score),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${section.score}/100',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: section.score / 100.0,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(height: 12),
          // Feedback Text
          Text(
            section.feedback,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
