// import 'package:flutter/material.dart';
// import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
// import 'package:graduation_project/view/screens/auth/register_screen.dart';
// import 'package:graduation_project/view/screens/home/home_screen.dart';
// import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
// import 'package:graduation_project/view/screens/splash/splashscreen.dart';

// // Simulated login & onboarding state
// bool isLoggedIn = false; // true if user logged in
// bool isRegistered = false; // true if user registered
// bool finishedOnboarding = false; // true if user finished onboarding

// class AppRouter {
//   static void checkAuth(BuildContext context) {
//     if (isLoggedIn) {
//       // Logged in → Home
//       Navigator.pushReplacementNamed(context, '/home');
//     } else if (isRegistered && !finishedOnboarding) {
//       // Registered but didn't finish onboarding → Onboarding
//       Navigator.pushReplacementNamed(context, '/onboard');
//     } else {
//       // Not logged in → Sign In
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case '/splash':
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case '/login':
//         return MaterialPageRoute(builder: (_) => const SignInScreen());
//       case '/register':
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
//       case '/home':
//         return MaterialPageRoute(builder: (_) => const HomeScreen());
//       case '/onboard':
//         return MaterialPageRoute(builder: (_) => const OnboardingGender());
//       default:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/home/home_screen.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/splash/splashscreen.dart';

// Simulated login & onboarding state
bool isLoggedIn = false;
bool isRegistered = false;
bool finishedOnboarding = false;

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

abstract class AppRouter {
  static GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // Redirect logic after splash
      if (state.location == '/') {
        if (isLoggedIn) {
          return '/home';
        } else if (isRegistered && !finishedOnboarding) {
          return '/onboard';
        } else {
          return '/login';
        }
      }
      return null; // no redirect
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardingGender(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}
