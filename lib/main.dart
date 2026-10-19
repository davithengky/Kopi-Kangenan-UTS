import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const KopkenApp());
}

class KopkenApp extends StatelessWidget {
  const KopkenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kopi Kangenan',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.maroon),
      ),
      home: const SplashScreen(),
    );
  }
}
