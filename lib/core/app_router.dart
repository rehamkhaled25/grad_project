// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
// import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
// import 'package:graduation_project/view/screens/auth/register_screen.dart';
// import 'package:graduation_project/view/screens/database/database_search.dart';
// import 'package:graduation_project/view/screens/home/dashboard.dart';
// import 'package:graduation_project/view/screens/home/documents_screen.dart';
// import 'package:graduation_project/view/screens/home/notifications_settings_screen.dart';
// import 'package:graduation_project/view/screens/home/profile_screen.dart';
// import 'package:graduation_project/view/screens/notifications/notifications_screen.dart';
// import 'package:graduation_project/view/screens/onboarding/allset.dart';
// import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
// import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
// import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
// import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
// import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
// import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
// import 'package:graduation_project/view/screens/progress/weekly_progress.dart';
// import 'package:graduation_project/view/screens/settings/settings_screen.dart';
// import 'package:graduation_project/view/screens/splash/splash.dart';
// import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
// import 'package:graduation_project/view/screens/home/scanner.dart';

// // Simulated auth & onboarding state (replace with actual state management)
// class AuthState {
//   static bool isLoggedIn = false;
//   static bool isRegistered = false;
//   static bool finishedOnboarding = false;
//   static bool hasSeenSplash = false;
// }

// final GlobalKey<NavigatorState> globalNavigatorKey =
//     GlobalKey<NavigatorState>();

// // Create a scaffold with bottom nav bar
// class ScaffoldWithBottomNavBar extends StatelessWidget {
//   final Widget child;

//   const ScaffoldWithBottomNavBar({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
//   }
// }

// abstract class AppRouter {
//   static GoRouter router = GoRouter(
//     navigatorKey: globalNavigatorKey,
//     initialLocation: '/splash',
//     redirect: (context, state) {
//       // Handle redirect logic
//       final location = state.location;

//       // If coming from splash, let it finish first
//       if (location == '/splash' && !AuthState.hasSeenSplash) {
//         return null;
//       }

//       // Check authentication status
//       if (AuthState.isLoggedIn) {
//         // If logged in and trying to access auth/onboarding pages, redirect to home
//         if (location == '/login' ||
//             location == '/register' ||
//             location.startsWith('/onboarding') ||
//             location == '/subscription') {
//           return '/home';
//         }
//         return null;
//       }

      
//       if (!AuthState.isRegistered) {
//         if (location != '/login' &&
//             location != '/register' &&
//             location != '/splash') {
//           return '/login';
//         }
//       }

//       return null;
//     },
//     routes: [
//       // Public routes (no bottom nav)
//       GoRoute(
//         path: '/splash',
//         name: 'splash',
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: '/login',
//         name: 'login',
//         builder: (context, state) => const SignInScreen(),
//       ),
//       GoRoute(
//         path: '/register',
//         name: 'register',
//         builder: (context, state) => const RegisterScreen(),
//       ),

//       // Onboarding routes
//       GoRoute(
//         path: '/onboardingGender',
//         name: 'onboarding_gender',
//         builder: (context, state) => const OnboardingGender(),
//       ),
//       GoRoute(
//         path: '/onboardingHeight',
//         name: 'onboarding_height',
//         builder: (context, state) => const HeightScreen(),
//       ),
//       GoRoute(
//         path: '/onboardingBirthdate',
//         name: 'onboarding_birthdate',
//         builder: (context, state) => const BirthDateScreen(),
//       ),
//       GoRoute(
//         path: '/onboardingWeight',
//         name: 'onboarding_weight',
//         builder: (context, state) => const WeightScreen(),
//       ),
//       GoRoute(
//         path: '/onboardingGoal',
//         name: 'onboarding_goal',
//         builder: (context, state) => const OnboardingGoal(),
//       ),
//       GoRoute(
//         path: '/onboardingNotification',
//         name: 'onboarding_notification',
//         builder: (context, state) => const NotificationPermissionPage(),
//       ),
//       GoRoute(
//         path: '/onboardingAllset',
//         name: 'onboarding_allset',
//         builder: (context, state) => const AllSet(),
//       ),
//       GoRoute(
//         path: '/subscription',
//         name: 'subscription',
//         builder: (context, state) => const TrialSubscriptionPage(),
//       ),
//       GoRoute(
//         path: '/profile',
//         name: 'profile',
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: '/notifications',
//         name: 'notifications',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: NotificationsSettingsScreen()),
//       ),
//       GoRoute(
//         path: '/notificationsScreen',
//         name: 'notificationsScreen',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: NotificationScreen()),
//       ),
//       GoRoute(
//         path: '/foodScanner',
//         name: 'food_scanner',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: FoodScannerScreen()),
//       ),

//       // Protected routes with bottom navigation bar
//       ShellRoute(
//         builder: (context, state, child) {
//           return ScaffoldWithBottomNavBar(child: child);
//         },
//         routes: [
//           GoRoute(
//             path: '/home',
//             name: 'home',
//             pageBuilder: (context, state) => const NoTransitionPage(
//               child: HomeScreen(), // Make sure HomeScreen is your dashboard
//             ),
//           ),
//           GoRoute(
//             path: '/log',
//             name: 'log',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: DatabaseSearch()),
//           ),
//           GoRoute(
//             path: '/progress',
//             name: 'progress',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: WeeklyProgress()),
//           ),

//           GoRoute(
//             path: '/settings',
//             name: 'settings',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: SettingsScreen()),
//           ),
//         ],
//       ),
//     ],
//     errorBuilder: (context, state) =>
//         Scaffold(body: Center(child: Text('Error: ${state.error}'))),
//   );
// }

// // Navigation helpers
// extension NavigationHelpers on BuildContext {
//   void goToLogin() => go('/login');
//   void goToRegister() => go('/register');
//   void goToHome() => go('/home');
//   void goToOnboardingGender() => go('/onboardingGender');
//   void goToOnboardingHeight() => go('/onboardingHeight');
//   void goToOnboardingBirthdate() => go('/onboardingBirthdate');
//   void goToOnboardingWeight() => go('/onboardingWeight');
//   void goToOnboardingGoal() => go('/onboardingGoal');
//   void goToOnboardingNotification() => go('/onboardingNotification');
//   void goToOnboardingAllSet() => go('/onboardingAllset');
//   void goToSubscription() => go('/subscription');
//   void goToFoodScanner() => go('/foodScanner');
//   void goToDocuments() => go('/documents');
//   void goToNotifications() => go('/notifications');
//   void goToSettings() => go('/settings');
//   void goToProfile() => go('/profile');

//   void logout() {
//     AuthState.isLoggedIn = false;
//     AuthState.isRegistered = false;
//     AuthState.finishedOnboarding = false;
//     go('/login');
//   }
// }




import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/database/database_search.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/notifications_settings_screen.dart';
import 'package:graduation_project/view/screens/home/profile_screen.dart';
import 'package:graduation_project/view/screens/notifications/notifications_screen.dart';
import 'package:graduation_project/view/screens/onboarding/allset.dart';
import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
import 'package:graduation_project/view/screens/progress/weekly_progress.dart';
import 'package:graduation_project/view/screens/settings/settings_screen.dart';
import 'package:graduation_project/view/screens/splash/splash.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
import 'package:graduation_project/view/screens/home/scanner.dart';

// Simulated auth & onboarding state
class AuthState {
  static bool isLoggedIn = false;
  static bool isRegistered = false;
  static bool finishedOnboarding = false;
  static bool hasSeenSplash = false;
}

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

// Create a scaffold with bottom nav bar
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
  }
}

abstract class AppRouter {
  static GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // 1. If coming from splash, let it finish first
      if (location == '/splash' && !AuthState.hasSeenSplash) {
        return null;
      }

      // 2. Handle Logic for Logged In Users
      if (AuthState.isLoggedIn) {
        // If they are logged in but HAVEN'T finished onboarding
        if (!AuthState.finishedOnboarding) {
          // If they try to go home or go back to login/register, force them to onboarding start
          if (location == '/home' || location == '/login' || location == '/register') {
            return '/onboardingGender';
          }
          // Otherwise, let them stay on the specific onboarding page they are currently on
          return null;
        }

        // If they ARE logged in AND finished onboarding, don't let them see Auth or Onboarding
        if (location == '/login' ||
            location == '/register' ||
            location.startsWith('/onboarding') ||
            location == '/subscription') {
          return '/home';
        }
        return null;
      }

      // 3. Handle Logic for Logged Out Users
      if (!AuthState.isLoggedIn) {
        // If not logged in, they can only be on splash, login, or register
        if (location != '/login' &&
            location != '/register' &&
            location != '/splash') {
          return '/login';
        }
      }

      return null;
    },
    routes: [
      // Public routes (no bottom nav)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Onboarding routes
      GoRoute(
        path: '/onboardingGender',
        name: 'onboarding_gender',
        builder: (context, state) => const OnboardingGender(),
      ),
      GoRoute(
        path: '/onboardingHeight',
        name: 'onboarding_height',
        builder: (context, state) => const HeightScreen(),
      ),
      GoRoute(
        path: '/onboardingBirthdate',
        name: 'onboarding_birthdate',
        builder: (context, state) => const BirthDateScreen(),
      ),
      GoRoute(
        path: '/onboardingWeight',
        name: 'onboarding_weight',
        builder: (context, state) => const WeightScreen(),
      ),
      GoRoute(
        path: '/onboardingGoal',
        name: 'onboarding_goal',
        builder: (context, state) => const OnboardingGoal(),
      ),
      GoRoute(
        path: '/onboardingNotification',
        name: 'onboarding_notification',
        builder: (context, state) => const NotificationPermissionPage(),
      ),
      GoRoute(
        path: '/onboardingAllset',
        name: 'onboarding_allset',
        builder: (context, state) => const AllSet(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const TrialSubscriptionPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: NotificationsSettingsScreen()),
      ),
      GoRoute(
        path: '/notificationsScreen',
        name: 'notificationsScreen',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: NotificationScreen()),
      ),
      GoRoute(
        path: '/foodScanner',
        name: 'food_scanner',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: FoodScannerScreen()),
      ),

      // Protected routes with bottom navigation bar
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/log',
            name: 'log',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DatabaseSearch()),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WeeklyProgress()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

// Navigation helpers
extension NavigationHelpers on BuildContext {
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToHome() => go('/home');
  void goToOnboardingGender() => go('/onboardingGender');
  void goToOnboardingHeight() => go('/onboardingHeight');
  void goToOnboardingBirthdate() => go('/onboardingBirthdate');
  void goToOnboardingWeight() => go('/onboardingWeight');
  void goToOnboardingGoal() => go('/onboardingGoal');
  void goToOnboardingNotification() => go('/onboardingNotification');
  void goToOnboardingAllSet() => go('/onboardingAllset');
  void goToSubscription() => go('/subscription');
  void goToFoodScanner() => go('/foodScanner');
  void goToDocuments() => go('/documents');
  void goToNotifications() => go('/notifications');
  void goToSettings() => go('/settings');
  void goToProfile() => go('/profile');

  void logout() {
    AuthState.isLoggedIn = false;
    AuthState.isRegistered = false;
    AuthState.finishedOnboarding = false;
    go('/login');
  }
}
