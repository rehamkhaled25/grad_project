import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/onboarding/allset.dart';
import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
import 'package:graduation_project/view/screens/splash/splash.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';

// Simulated auth & onboarding state (replace with actual state management)
class AuthState {
  static bool isLoggedIn = false;
  static bool isRegistered = false;
  static bool finishedOnboarding = false;
  static bool hasSeenSplash = false;
}

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

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
            location.startsWith('/onboarding') || // Changed from '/onboarding/'
            location == '/subscription') {
          return '/home';
        }
        return null;
      }

      // Not logged in - check registration flow
      // if (AuthState.isRegistered && !AuthState.finishedOnboarding) {
      //   // If registered but onboarding not finished, only allow onboarding pages
      //   // Check if location starts with any onboarding route
      //   if (!location.startsWith('/onboarding')) {
      //     // Changed from '/onboarding/'
      //     return '/onboardingGender';
      //   }
      //   return null;
      // }

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
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
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

      // Subscription route
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const TrialSubscriptionPage(),
      ),

      // Home route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

// Add these helper methods to your AppRouter class
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

  void logout() {
    AuthState.isLoggedIn = false;
    AuthState.isRegistered = false;
    AuthState.finishedOnboarding = false;
    go('/login');
  }
}
