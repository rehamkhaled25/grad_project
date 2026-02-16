import 'package:flutter/material.dart';
import 'package:graduation_project/core/app_router.dart';

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
      debugShowCheckedModeBanner: false,
    );
  }
}
