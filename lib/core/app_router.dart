import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/documents_screen.dart';
import 'package:graduation_project/view/screens/home/notifications_screen.dart';
import 'package:graduation_project/view/screens/home/profile_screen.dart';
import 'package:graduation_project/view/screens/home/settings_screen.dart';
import 'package:graduation_project/view/screens/onboarding/allset.dart';
import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
import 'package:graduation_project/view/screens/splash/splash.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
import 'package:graduation_project/view/screens/home/scanner.dart';

// Simulated auth & onboarding state (replace with actual state management)
class AuthState {
  static bool isLoggedIn = false;
  static bool isRegistered = false;
  static bool finishedOnboarding = false;
  static bool hasSeenSplash = false;
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

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
      // Handle redirect logic
      final location = state.location;

      // If coming from splash, let it finish first
      if (location == '/splash' && !AuthState.hasSeenSplash) {
        return null;
      }

      // Check authentication status
      if (AuthState.isLoggedIn) {
        // If logged in and trying to access auth/onboarding pages, redirect to home
        if (location == '/login' ||
            location == '/register' ||
            location.startsWith('/onboarding') ||
            location == '/subscription') {
          return '/home';
        }
        return null;
      }

      // Not registered - only allow auth pages
      if (!AuthState.isRegistered) {
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
              child: HomeScreen(), // Make sure HomeScreen is your dashboard
            ),
          ),
          GoRoute(
            path: '/documents',
            name: 'documents',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DocumentsScreen()),
          ),
          GoRoute(
            path: '/foodScanner',
            name: 'food_scanner',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FoodScannerScreen()),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NotificationsScreen()),
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
