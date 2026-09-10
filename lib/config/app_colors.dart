import 'package:flutter/material.dart';

/// Centralized color palette and threshold logic for HireReady.
///
/// Avoids hardcoded colors across widgets and provides consistent visual feedback
/// for score levels (Red for low, Amber for medium, Green for high score).
class AppColors {
  // Brand Primary & Accent Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color accent = Color(0xFF0EA5E9); // Sky Blue

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Score Color Thresholds
  static const Color scoreLow = Color(0xFFEF4444); // Red (< 50)
  static const Color scoreLowBg = Color(0xFFFEF2F2);

  static const Color scoreMedium = Color(0xFFF59E0B); // Amber (50 - 74)
  static const Color scoreMediumBg = Color(0xFFFFFBEB);

  static const Color scoreHigh = Color(0xFF10B981); // Green (75+)
  static const Color scoreHighBg = Color(0xFFECFDF5);

  /// Returns appropriate color based on score (0 to 100)
  /// - Red: < 50 (Needs Improvement)
  /// - Amber: 50 - 74 (Average / Good)
  /// - Green: 75+ (Strong / Excellent)
  static Color getScoreColor(int score) {
    if (score < 50) {
      return scoreLow;
    } else if (score < 75) {
      return scoreMedium;
    } else {
      return scoreHigh;
    }
  }

  /// Returns light background tint matching the score level
  static Color getScoreBgColor(int score) {
    if (score < 50) {
      return scoreLowBg;
    } else if (score < 75) {
      return scoreMediumBg;
    } else {
      return scoreHighBg;
    }
  }

  /// Returns friendly human-readable label for score
  static String getScoreLabel(int score) {
    if (score < 50) {
      return 'Needs Improvement';
    } else if (score < 75) {
      return 'Good Start';
    } else if (score < 85) {
      return 'Strong Resume';
    } else {
      return 'Excellent Resume';
    }
  }
}
