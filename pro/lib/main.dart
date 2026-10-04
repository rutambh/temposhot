import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'presentation/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TempoShotApp(),
    ),
  );
}

class TempoShotApp extends StatelessWidget {
  const TempoShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempoShot Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        primaryColor: AppColors.blaze,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.blaze,
          secondary: AppColors.olive,
          surface: AppColors.blackCard,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
