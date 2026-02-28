import 'package:flutter/material.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/log_food.dart';
import 'package:graduation_project/view/screens/progress/weekly_progress.dart';





void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GraduationProjectApp());
}

class GraduationProjectApp extends StatelessWidget {
  const GraduationProjectApp({super.key});

  @override
  Widget build(BuildContext context) {


   return MaterialApp.router(
      title: 'Cal Ai',
      routerConfig: AppRouter.router,
    // home: LogFood(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Figtree'
      ),
    );

  }
}
