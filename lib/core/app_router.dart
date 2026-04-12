import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/models/user_model.dart';
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
import 'package:graduation_project/view/screens/streak/streak_screen.dart';

// Simulated auth & onboarding state
class AuthState {
  static bool isLoggedIn = false;
  static bool isRegistered = false;
  static bool finishedOnboarding = false;
  static bool hasSeenSplash = false;
}

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

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

      // 1. SPLASH SAFE ZONE
      // If we are currently on splash, stay there and don't evaluate other rules.
      if (location == '/splash') {
        return null;
      }

      // 2. LOGGED IN LOGIC
      if (AuthState.isLoggedIn) {
        if (!AuthState.finishedOnboarding) {
          if (location == '/home' || location == '/login' || location == '/register') {
            return '/onboardingGender';
          }
          return null;
        }

        if (location == '/login' || 
            location == '/register' || 
            location.startsWith('/onboarding')) {
          return '/home';
        }
        return null;
      }

      // 3. LOGGED OUT LOGIC (FIXED)
      if (!AuthState.isLoggedIn) {
        // If they are not logged in, they are ONLY allowed to be on 
        // splash, login, register, or the onboarding flow.
        // If they try to go anywhere else (like /home), send them to login.
        if (location != '/login' && 
            location != '/register' && 
            !location.startsWith('/onboarding')) {
          return '/login';
        }
      }

      return null;
    },
    routes: [
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
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return RegisterScreen(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingGender',
        name: 'onboarding_gender',
        builder: (context, state) => const OnboardingGender(),
      ),
      GoRoute(
        path: '/onboardingHeight',
        name: 'onboarding_height',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return HeightScreen(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingBirthdate',
        name: 'onboarding_birthdate',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return BirthDateScreen(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingWeight',
        name: 'onboarding_weight',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return WeightScreen(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingGoal',
        name: 'onboarding_goal',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return OnboardingGoal(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingNotifications',
        name: 'onboarding_notifications',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return NotificationPermissionPage(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingAllSet',
        name: 'onboarding_allset',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return AllSet(userModel: extra);
        },
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
        pageBuilder: (context, state) => const NoTransitionPage(child: NotificationsSettingsScreen()),
      ),
      GoRoute(
        path: '/notificationsScreen',
        name: 'notificationsScreen',
        pageBuilder: (context, state) => const NoTransitionPage(child: NotificationScreen()),
      ),
      GoRoute(
        path: '/foodScanner',
        name: 'food_scanner',
        pageBuilder: (context, state) => const NoTransitionPage(child: FoodScannerScreen()),
      ),
      GoRoute(
        path: '/streak',
        name: 'streak',
        pageBuilder: (context, state) => const NoTransitionPage(child: StreakScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/log',
            name: 'log',
            pageBuilder: (context, state) => const NoTransitionPage(child: DatabaseSearch()),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) => const NoTransitionPage(child: WeeklyProgress()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
}

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
  void goToNotifications() => go('/notifications');
  void goToSettings() => go('/settings');
  void goToProfile() => go('/profile');
  void goToStreak() => go('/streak');

  void logout() {
    AuthState.isLoggedIn = false;
    AuthState.isRegistered = false;
    AuthState.finishedOnboarding = false;
    go('/login');
  }
}