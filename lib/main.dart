import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
// 1. Ensure you have the options import
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // 2. The ONLY thing needed for most modern Flutter/Firebase apps
  // This handles Web, Android, and iOS automatically using your file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cal Ai',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Figtree'),
    );
  }
}