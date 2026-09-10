import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service responsible for file picking and text extraction from resumes.
///
/// Handles PDF extraction via [syncfusion_flutter_pdf] and plain text files.
/// Includes beginner-friendly error handling for missing text layers or unreadable files.
class FileService {
  /// Opens device file picker restricted to PDF, DOCX, and TXT files.
  static Future<PlatformFile?> pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true, // Loads bytes into memory (essential for web/android path compatibility)
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: ${e.toString()}');
    }
  }

  /// Extracts plain text from picked resume file based on extension.
  static Future<String> extractText(PlatformFile platformFile) async {
    final extension = platformFile.extension?.toLowerCase() ?? '';

    String extractedText = '';

    if (extension == 'pdf') {
      extractedText = await _extractTextFromPdf(platformFile);
    } else if (extension == 'txt') {
      extractedText = await _extractTextFromTxt(platformFile);
    } else if (extension == 'docx') {
      extractedText = await _extractTextFromDocx(platformFile);
    } else {
      throw Exception(
          'Unsupported file format (.$extension). Please upload a PDF, DOCX, or TXT file.');
    }

    // Sanitize and validate minimum text content length
    final trimmed = extractedText.trim();
    if (trimmed.length < 30) {
      throw Exception(
          'Could not extract sufficient readable text from this file.\n'
          'If this is a scanned PDF image, please try using a text-searchable PDF or TXT file.');
    }

    return trimmed;
  }

  /// PDF extraction using Syncfusion PDF Extractor
  static Future<String> _extractTextFromPdf(PlatformFile platformFile) async {
    try {
      List<int>? bytes = platformFile.bytes;

      // If bytes not loaded in memory, try reading from file path
      if (bytes == null && platformFile.path != null) {
        final file = File(platformFile.path!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Unable to read file content bytes.');
      }

      // Load PDF document from bytes
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract all text across pages
      final String text = PdfTextExtractor(document).extractText();

      // Dispose document to free memory
      document.dispose();

      return text;
    } catch (e) {
      throw Exception('PDF Extraction Error: ${e.toString()}');
    }
  }

  /// Text file reader
  static Future<String> _extractTextFromTxt(PlatformFile platformFile) async {
    if (platformFile.bytes != null) {
      return utf8.decode(platformFile.bytes!, allowMalformed: true);
    } else if (platformFile.path != null) {
      final file = File(platformFile.path!);
      return await file.readAsString();
    }
    throw Exception('Unable to read TXT file content.');
  }

  /// DOCX text extraction handling
  /// Note for beginner explanation: DOCX files are compressed XML archives.
  /// For this client-side Flutter app, we extract plain text fragments from the document bytes.
  static Future<String> _extractTextFromDocx(PlatformFile platformFile) async {
    try {
      List<int>? bytes = platformFile.bytes;
      if (bytes == null && platformFile.path != null) {
        final file = File(platformFile.path!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Unable to read DOCX file bytes.');
      }

      // Attempt to extract string characters from docx xml stream
      final String rawText = utf8.decode(bytes, allowMalformed: true);
      
      // Clean up XML tags and extract readable text content
      final RegExp xmlTagRegex = RegExp(r'<[^>]*>');
      final String textWithoutTags = rawText.replaceAll(xmlTagRegex, ' ');
      final String cleanedText = textWithoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanedText.length >= 30) {
        return cleanedText;
      }
      
      throw Exception('DOCX format requires converting to PDF or TXT for best accuracy.');
    } catch (e) {
      throw Exception(
          'DOCX parsing error. For best accuracy, please save/export your resume as PDF or TXT.');
    }
  }
}
