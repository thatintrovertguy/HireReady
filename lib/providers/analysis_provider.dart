import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/resume_analysis.dart';
import '../services/file_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

/// Represents the distinct states of the async resume analysis pipeline.
enum AnalysisState {
  idle, // Waiting for user to select a file
  loading, // File parsing & AI API evaluation in progress
  success, // Analysis completed successfully
  error, // An error occurred (e.g. unreadable file, network error)
}

/// Provider managing state for the entire HireReady app lifecycle.
///
/// Uses Flutter's [ChangeNotifier] pattern (Provider package).
/// UI components subscribe via `Consumer<AnalysisProvider>` or `context.watch<AnalysisProvider>()`
/// and automatically rebuild when `notifyListeners()` is invoked.
class AnalysisProvider extends ChangeNotifier {
  // Current app state enum
  AnalysisState _state = AnalysisState.idle;
  AnalysisState get state => _state;

  // Selected file picked from device
  PlatformFile? _selectedFile;
  PlatformFile? get selectedFile => _selectedFile;

  // Final evaluation result
  ResumeAnalysis? _currentAnalysis;
  ResumeAnalysis? get currentAnalysis => _currentAnalysis;

  // Friendly user-facing error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Rotating loading message for feedback during async steps
  String _statusMessage = 'Reading your resume...';
  String get statusMessage => _statusMessage;

  /// Picks a PDF, DOCX, or TXT file using [FileService].
  Future<void> pickResumeFile() async {
    try {
      final file = await FileService.pickResumeFile();
      if (file != null) {
        _selectedFile = file;
        _errorMessage = null;
        if (_state == AnalysisState.error) {
          _state = AnalysisState.idle;
        }
        notifyListeners(); // Rebuild UI to display selected file card
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AnalysisState.error;
      notifyListeners();
    }
  }

  /// Clears selected file and resets state to idle.
  void clearFile() {
    _selectedFile = null;
    _currentAnalysis = null;
    _errorMessage = null;
    _state = AnalysisState.idle;
    notifyListeners();
  }

  /// Main orchestrator function: File Text Extraction -> AI Service -> Local Persistence.
  ///
  /// Calls `notifyListeners()` at every stage transition so UI screens can
  /// dynamically display progress updates ("Reading...", "Analyzing...").
  Future<void> analyzeResume(String? targetRole) async {
    if (_selectedFile == null) {
      _errorMessage = 'Please select a resume file (PDF, DOCX, or TXT) before analyzing.';
      _state = AnalysisState.error;
      notifyListeners();
      return;
    }

    try {
      // Step 1: Set loading state and initial progress message
      _state = AnalysisState.loading;
      _statusMessage = 'Reading and extracting text from resume...';
      _errorMessage = null;
      notifyListeners();

      // Step 2: Extract text from file
      final extractedText = await FileService.extractText(_selectedFile!);

      // Step 3: Update progress message for AI generation stage
      _statusMessage = 'Analyzing structure, keywords & score with AI...';
      notifyListeners();

      // Step 4: Send text to AI Service
      final analysis = await AiService.analyzeResume(
        resumeText: extractedText,
        targetRole: targetRole,
        fileName: _selectedFile!.name,
      );

      // Step 5: Save analysis to local Hive database history
      await StorageService.saveAnalysis(analysis);

      // Step 6: Mark success state and store result
      _currentAnalysis = analysis;
      _state = AnalysisState.success;
      notifyListeners();
    } catch (e) {
      // Handle all errors gracefully without raw stack trace crashes
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AnalysisState.error;
      notifyListeners();
    }
  }

  /// Re-opens a saved analysis from history screen directly into results screen.
  void loadSavedAnalysis(ResumeAnalysis analysis) {
    _currentAnalysis = analysis;
    _state = AnalysisState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets state back to idle for starting a new analysis.
  void reset() {
    _state = AnalysisState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
