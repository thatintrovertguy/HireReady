# HireReady — AI-Powered Resume Analyzer 🎯

HireReady is a modern, cross-platform Flutter application built to help job seekers optimize their resumes. Using Large Language Models (Google Gemini API), HireReady extracts resume text, analyzes content structure, evaluates target job role alignment, and delivers actionable, section-by-section feedback with an overall score gauge.

---

## 📸 Key Highlights & Features

- 📄 **Multi-Format Text Extraction**: Extracts text seamlessly from PDF, DOCX, and TXT resume files using Syncfusion PDF parsing.
- 🎯 **Target Job Role Matching**: Evaluates resume alignment against specific target job roles (e.g., *Flutter Developer*, *Data Analyst*), providing a **Match %** score and highlighting **missing industry keywords**.
- 📊 **Animated Circular Score Gauge**: Displays an overall resume score (0–100) with dynamic threshold color-coding:
  - 🔴 **< 50**: Needs Improvement
  - 🟠 **50–74**: Good Start
  - 🟢 **75+**: Strong / Excellent Resume
- 📋 **5-Section Breakdown**: Detailed evaluation across core sections:
  1. **Summary**: Headline clarity & value proposition
  2. **Skills**: Technical stack relevance & framework keywords
  3. **Experience**: Action verbs, metrics, and bullet point structure
  4. **Education**: Degree details & formatting alignment
  5. **Formatting**: Consistent layout, indentation, and typography
- 💡 **Actionable Recommendations**: Bulleted, high-impact suggestions to instantly strengthen resume quality.
- 📁 **Offline History Persistence**: Local database powered by `Hive` automatically stores evaluation results on-device for instant offline access.
- 📄 **Exportable PDF Reports**: Generates and exports styled PDF summary reports using `pdf` and `printing` packages.
- 🔄 **Smart Offline Fallback Mode**: Built-in mock data generator allows offline testing and seamless live demonstrations without an active API key or internet connection.

---

## 🛠 Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: `provider` (`ChangeNotifier` pattern)
- **Local Persistence**: `hive` & `hive_flutter`
- **PDF Extraction & Generation**: `syncfusion_flutter_pdf`, `pdf`, `printing`
- **UI Components & Indicator**: `percent_indicator`, `cupertino_icons`, Material 3
- **Networking**: `http` (Google Gemini REST API integration)

---

## 📁 Project Architecture

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart        # API key & Gemini LLM endpoint configuration
│   └── app_colors.dart        # Centralized color palette & score threshold logic
├── models/
│   └── resume_analysis.dart   # ResumeAnalysis & SectionScore data models
├── services/
│   ├── ai_service.dart        # Prompt engineering, JSON contract enforcement & mock fallback
│   ├── file_service.dart      # File picker & text extraction (PDF / DOCX / TXT)
│   ├── storage_service.dart   # Hive local database persistence for evaluation history
│   └── pdf_export_service.dart# Styled PDF report generator and exporter
├── providers/
│   └── analysis_provider.dart # ChangeNotifier state orchestrator
├── screens/
│   ├── home_screen.dart       # File upload & target role input screen
│   ├── loading_screen.dart    # Animated progress screen with rotating status messages
│   ├── results_screen.dart    # Score gauge, section cards, missing keywords & suggestions
│   └── history_screen.dart    # List of saved past resume evaluations
└── widgets/
    ├── score_gauge.dart       # Circular score gauge (0–100) using percent_indicator
    ├── section_card.dart      # Color-coded section breakdown card
    ├── suggestion_tile.dart   # Bulleted improvement suggestion tile
    └── match_badge.dart       # Target job role match percentage badge
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or VS Code
- Android Device or Emulator

### Installation & Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/hireready.git
   cd hireready
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Key (Optional)**:
   Open `lib/config/api_config.dart` and insert your [Google AI Studio](https://aistudio.google.com/) Gemini API key:
   ```dart
   class ApiConfig {
     static const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   }
   ```
   *(Note: If left as `YOUR_API_KEY_HERE`, HireReady automatically uses its built-in offline mock mode).*

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
