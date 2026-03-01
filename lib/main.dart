import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added this
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/log_food.dart';
import 'package:graduation_project/view/screens/home/scanner.dart';
import 'package:graduation_project/view/screens/progress/weekly_progress.dart';

// Changed to Future and async to support dotenv loading
Future<void> main() async {
  // Ensures Flutter framework is ready before loading assets
  WidgetsFlutterBinding.ensureInitialized();
  
  // Loads the .env file from your project root
  await dotenv.load(fileName: ".env");
  
  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cal Ai',
      // routerConfig: AppRouter.router,
      home: const FoodScannerScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Figtree',
      ),
    );
  }
}
