/// API Configuration for HireReady
///
/// This file centralizes API settings for the LLM service.
/// For a college portfolio/exhibition project, we support both a live API key
/// and a high-quality mock response mode so the app works seamlessly even without an API key.
class ApiConfig {
  // =========================================================================
  // REPLACE THIS PLACEHOLDER WITH YOUR ACTUAL GOOGLE GEMINI / OPENAI API KEY
  // =========================================================================
  // Example: static const String apiKey = 'AIzaSyD-YourActualGeminiApiKeyHere';
  static const String apiKey = 'YOUR_API_KEY_HERE';

  /// Google Gemini API endpoint using stable `gemini-1.5-flash` model
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Helper getter to check if a real API key has been provided by the user.
  /// If the key is empty or still set to the placeholder string, the app will
  /// use realistic mock data so you can test and demonstrate the app UI offline!
  static bool get isApiKeyConfigured {
    return apiKey.isNotEmpty &&
        apiKey != 'YOUR_API_KEY_HERE' &&
        !apiKey.startsWith('YOUR_');
  }
}

