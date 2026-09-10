import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/app_colors.dart';

/// Animated Circular Score Gauge displaying overall resume score (0 to 100).
/// Color transitions dynamically from Red -> Amber -> Green based on score level.
class ScoreGauge extends StatelessWidget {
  final int score;
  final double radius;

  const ScoreGauge({
    super.key,
    required this.score,
    this.radius = 85.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = AppColors.getScoreColor(score);
    final String scoreLabel = AppColors.getScoreLabel(score);
    final double percent = (score.clamp(0, 100)) / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: 14.0,
          percent: percent,
          animation: true,
          animationDuration: 1200,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: scoreColor.withValues(alpha: 0.15),
          progressColor: scoreColor,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 42.0,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'OUT OF 100',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            scoreLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
      ],
    );
  }
}
