import 'package:hive_flutter/hive_flutter.dart';
import '../models/resume_analysis.dart';

/// Local Storage Service powered by [Hive].
///
/// Persists past resume analyses locally on device without needing a custom database
/// or remote backend. Perfect for offline history lookup in student portfolio projects.
class StorageService {
  static const String _boxName = 'analysis_history';
  static Box? _box;

  /// Initializes Hive database and opens history box with self-healing recovery.
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox(_boxName);
      } catch (_) {
        // Fallback: If Hive storage fails, app runs smoothly without history persistence
      }
    }
  }

  /// Ensures Hive box is open before executing database queries.
  static Future<Box?> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      try {
        _box = await Hive.openBox(_boxName);
      } catch (_) {
        return null;
      }
    }
    return _box;
  }

  /// Saves a new resume analysis to local storage history.
  static Future<void> saveAnalysis(ResumeAnalysis analysis) async {
    try {
      final box = await _getBox();
      if (box != null) {
        await box.put(analysis.id, analysis.toJson());
      }
    } catch (e) {
      // Log storage error quietly without crashing user flow
    }
  }

  /// Retrieves all saved past analyses sorted by newest first.
  static Future<List<ResumeAnalysis>> getHistory() async {
    try {
      final box = await _getBox();
      if (box == null) return [];
      final List<ResumeAnalysis> list = [];

      for (var key in box.keys) {
        final Map<dynamic, dynamic>? rawMap = box.get(key);
        if (rawMap != null) {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawMap);
          list.add(ResumeAnalysis.fromJson(jsonMap));
        }
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Deletes a specific item from history.
  static Future<void> deleteAnalysis(String id) async {
    try {
      final box = await _getBox();
      if (box != null) {
        await box.delete(id);
      }
    } catch (e) {
      // Handle gracefully
    }
  }

  /// Clears all historical records from local database.
  static Future<void> clearHistory() async {
    try {
      final box = await _getBox();
      if (box != null) {
        await box.clear();
      }
    } catch (e) {
      // Handle gracefully
    }
  }
}
