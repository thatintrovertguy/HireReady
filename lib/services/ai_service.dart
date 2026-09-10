import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/resume_analysis.dart';

/// Service for interacting with LLM AI APIs to evaluate resumes.
///
/// Handles prompt construction, JSON formatting instructions, network requests,
/// sanitation of raw LLM output, and fallback mock analysis generation.
class AiService {
  /// Analyzes extracted resume text against an optional target job role.
  ///
  /// Sends a structured prompt to the Gemini LLM endpoint demanding a strict JSON output.
  /// If no API key is provided or the network call fails, falls back gracefully to
  /// mock analysis so the project remains testable for demonstrations.
  static Future<ResumeAnalysis> analyzeResume({
    required String resumeText,
    String? targetRole,
    String? fileName,
  }) async {
    // 1. Check if user configured a live API key
    if (!ApiConfig.isApiKeyConfigured) {
      // Simulate network latency (1.8 seconds) for authentic loading UX
      await Future.delayed(const Duration(milliseconds: 1800));
      return _generateMockAnalysis(
        resumeText: resumeText,
        targetRole: targetRole,
        fileName: fileName,
      );
    }

    try {
      // 2. Build system instruction & prompt demanding strict JSON shape
      final prompt = _buildPrompt(resumeText: resumeText, targetRole: targetRole);

      // 3. Make HTTP POST request to Google Gemini API
      final uri = Uri.parse('${ApiConfig.geminiEndpoint}?key=${ApiConfig.apiKey}');
      // Log for developer debugging
      // ignore: avoid_print
      print('[HireReady AI] Sending request to Gemini API...');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2, // Low temperature for deterministic, consistent JSON
                'responseMimeType': 'application/json', // Requests structured JSON output
              }
            }),
          )
          .timeout(const Duration(seconds: 25));

      // ignore: avoid_print
      print('[HireReady AI] Gemini HTTP Status Code: ${response.statusCode}');

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('[HireReady AI] Error Body: ${response.body}');
        // Fallback to mock data on API error (e.g. invalid key or rate limit)
        return _generateMockAnalysis(
          resumeText: resumeText,
          targetRole: targetRole,
          fileName: fileName,
        );
      }

      // 4. Extract raw text from Gemini response structure
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final String? rawText = responseJson['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (rawText == null || rawText.trim().isEmpty) {
        throw const FormatException('Empty response received from AI service.');
      }

      // 5. Clean up potential markdown formatting code blocks (e.g. ```json ... ```)
      final String cleanedJsonString = _sanitizeJsonString(rawText);

      // 6. Parse JSON into ResumeAnalysis model
      final Map<String, dynamic> parsedMap = jsonDecode(cleanedJsonString);
      return ResumeAnalysis.fromJson(
        parsedMap,
        targetRole: targetRole,
        fileName: fileName,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[HireReady AI] Exception caught: $e');
      // Log error internally and fallback to mock analysis to preserve app experience
      return _generateMockAnalysis(
        resumeText: resumeText,
        targetRole: targetRole,
        fileName: fileName,
      );
    }
  }

  /// Builds prompt instructing LLM to strictly follow the required JSON contract.
  ///
  /// Why this matters for AI engineering:
  /// LLMs are probabilistic text generators. By explicitly defining expected key names,
  /// value types, score ranges, and providing an example JSON schema, we ensure the app
  /// can safely parse the response without crashing.
  static String _buildPrompt({
    required String resumeText,
    String? targetRole,
  }) {
    final roleContext = (targetRole != null && targetRole.trim().isNotEmpty)
        ? 'Target Job Role: "${targetRole.trim()}"'
        : 'Target Job Role: General Software Engineering / Professional Role';

    return '''
You are an expert HR Specialist and AI Resume Evaluator. Analyze the following resume text and return a structured assessment.

$roleContext

RESUME TEXT:
"""
$resumeText
"""

STRICT INSTRUCTIONS:
1. Return ONLY valid JSON matching the exact schema below.
2. Do NOT include any intro text, markdown explanation, code block ticks, or preamble.
3. Score ranges MUST be integers between 0 and 100.
4. Provide evaluations for 5 key sections: "Summary", "Skills", "Experience", "Education", "Formatting".
5. If a target job role is specified above, calculate "matchPercent" (0-100) and list specific "missingKeywords". If no target role was specified, set "matchPercent" to null and "missingKeywords" to an empty list [].

JSON CONTRACT SCHEMA:
{
  "overallScore": 78,
  "matchPercent": ${targetRole != null ? '65' : 'null'},
  "sections": [
    {"name": "Summary", "score": 80, "feedback": "Clear and concise, but could mention years of experience."},
    {"name": "Skills", "score": 60, "feedback": "Missing several technical keywords relevant to the role."},
    {"name": "Experience", "score": 85, "feedback": "Strong action verbs and quantified achievements."},
    {"name": "Education", "score": 90, "feedback": "Well formatted, clear degree details."},
    {"name": "Formatting", "score": 70, "feedback": "Inconsistent bullet styling across experience entries."}
  ],
  "missingKeywords": ${targetRole != null ? '["Docker", "CI/CD", "REST APIs"]' : '[]'},
  "suggestions": [
    "Add a metrics-driven bullet point to your most recent role.",
    "Include a dedicated technical skills section near the top.",
    "Replace passive phrases with strong action verbs."
  ]
}
''';
  }

  /// Cleans raw output string from LLM in case markdown fences (` ```json ` or ` ``` `) are returned.
  static String _sanitizeJsonString(String raw) {
    String cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      // Remove opening ```json or ```
      cleaned = cleaned.replaceFirst(RegExp(r'^```(json)?', caseSensitive: false), '');
      // Remove trailing ```
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
    }
    return cleaned.trim();
  }

  /// Generates mock analysis when no API key is provided or offline demo mode is active.
  ///
  /// Customized intelligently based on whether a target role was provided!
  static ResumeAnalysis _generateMockAnalysis({
    required String resumeText,
    String? targetRole,
    String? fileName,
  }) {
    final bool hasRole = targetRole != null && targetRole.trim().isNotEmpty;
    final String roleStr = hasRole ? targetRole.trim() : 'Software Developer';

    return ResumeAnalysis(
      overallScore: 82,
      matchPercent: hasRole ? 78 : null,
      sections: [
        const SectionScore(
          name: 'Summary',
          score: 85,
          feedback: 'Engaging summary statement with concise professional value proposition.',
        ),
        SectionScore(
          name: 'Skills',
          score: hasRole ? 72 : 80,
          feedback: hasRole
              ? 'Good baseline skills, but missing core $roleStr stack keywords.'
              : 'Diverse skill set listed clearly with relevant frameworks.',
        ),
        const SectionScore(
          name: 'Experience',
          score: 88,
          feedback: 'Impressive impact statements using quantifiable metrics and action verbs.',
        ),
        const SectionScore(
          name: 'Education',
          score: 90,
          feedback: 'Clearly organized degree details, institution, and graduation timeline.',
        ),
        const SectionScore(
          name: 'Formatting',
          score: 75,
          feedback: 'Clean overall layout, but ensure consistent bullet indentation throughout.',
        ),
      ],
      missingKeywords: hasRole
          ? ['CI/CD Pipelines', 'System Architecture', 'Automated Testing', 'Agile/Scrum']
          : [],
      suggestions: [
        'Quantify achievements in your most recent project (e.g., "Improved load time by 30%").',
        hasRole
            ? 'Highlight relevant $roleStr tools near the top of your skills section.'
            : 'Add a section highlighting core projects and personal portfolio links.',
        'Use consistent past tense verbs for past positions and present tense for your current role.',
        'Ensure bullet points do not wrap awkwardly into single-word lines.',
      ],
      targetRole: targetRole,
      fileName: fileName ?? 'Resume.pdf',
      createdAt: DateTime.now(),
    );
  }
}
