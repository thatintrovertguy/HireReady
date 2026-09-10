import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_colors.dart';
import 'providers/analysis_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() {
  // Ensure Flutter engine bindings are initialized before async startup calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database (Hive) asynchronously so main app UI launches immediately
  StorageService.init();

  runApp(const HireReadyApp());
}

class HireReadyApp extends StatelessWidget {
  const HireReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AnalysisProvider>(
      create: (_) => AnalysisProvider(),
      child: MaterialApp(
        title: 'HireReady',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
