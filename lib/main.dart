// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:graduation_project/core/app_router.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:graduation_project/view/screens/database/servings_database.dart';
// // 1. Ensure you have the options import
// import 'firebase_options.dart'; 

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Load environment variables
//   await dotenv.load(fileName: ".env");

//   // 2. The ONLY thing needed for most modern Flutter/Firebase apps
//   // This handles Web, Android, and iOS automatically using your file
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const GraduationProjectApp());
// }

// class GraduationProjectApp extends StatelessWidget {
//   const GraduationProjectApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cal Ai',
//       home: ServingsDatabase(),
//       // routerConfig: AppRouter.router,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(fontFamily: 'Figtree'),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation_project/view/screens/database/servings_database.dart';
// import 'firebase_options.dart';   // ← you can keep this import or remove it

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // ────────────────────────────────────────────────
  //   IMPORTANT: We removed the manual Firebase.initializeApp()
  //   call because the google-services.json file already initializes
  //   the default Firebase app automatically on Android.
  //   Keeping it causes the "duplicate app" crash.
  // ────────────────────────────────────────────────

  // If you ever need to support multiple Firebase projects or flavors,
  // you can add conditional initialization later like this:
  //
  // if (Firebase.apps.isEmpty) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }

  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cal Ai',
      home: const ServingsDatabase(),
      // routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Figtree'),
    );
  }
}