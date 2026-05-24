// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/models/user_model.dart';
// import 'package:graduation_project/view/custom _widget/custom_navbar.dart';
// import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
// import 'package:graduation_project/view/screens/auth/register_screen.dart';
// import 'package:graduation_project/view/screens/database/database_search.dart';
// import 'package:graduation_project/view/screens/home/dashboard.dart';
// import 'package:graduation_project/view/screens/home/log_food.dart';
// import 'package:graduation_project/view/screens/home/notifications_settings_screen.dart';
// import 'package:graduation_project/view/screens/home/profile_screen.dart';
// import 'package:graduation_project/view/screens/notifications/notifications_screen.dart';
// import 'package:graduation_project/view/screens/onboarding/allergies.dart';
// import 'package:graduation_project/view/screens/onboarding/allset.dart';
// import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
// import 'package:graduation_project/view/screens/onboarding/goalWeight.dart';
// import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
// import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
// import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
// import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
// import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
// import 'package:graduation_project/view/screens/payment/creditcardinfo.dart';
// import 'package:graduation_project/view/screens/payment/payment_application.dart';
// import 'package:graduation_project/view/screens/plan/plan.dart';
// import 'package:graduation_project/view/screens/progress/progress.dart';
// import 'package:graduation_project/view/screens/progress/weekly_breakdown_screen.dart';
// import 'package:graduation_project/view/screens/progress/weekly_progress.dart';
// import 'package:graduation_project/view/screens/settings/settings_screen.dart';
// import 'package:graduation_project/view/screens/splash/splash.dart';
// import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
// import 'package:graduation_project/view/screens/home/scanner.dart';
// import 'package:graduation_project/view/screens/streak/streak_screen.dart';

// // Simulated auth & onboarding state
// class AuthState {
//   static bool isLoggedIn = false;
//   static bool isRegistered = false;
//   static bool finishedOnboarding = false;
//   static bool hasSeenSplash = false;
// }

// final GlobalKey<NavigatorState> globalNavigatorKey =
//     GlobalKey<NavigatorState>();

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
//       final location = state.matchedLocation;

//       // 1. SPLASH SAFE ZONE
//       if (location == '/splash') {
//         return null;
//       }

//       // 2. LOGGED IN LOGIC
//       if (AuthState.isLoggedIn) {
//         if (!AuthState.finishedOnboarding) {
//           if (location == '/home' ||
//               location == '/login' ||
//               location == '/register') {
//             return '/onboardingGender';
//           }
//           return null;
//         }

//         if (location == '/login' ||
//             location == '/register' ||
//             location.startsWith('/onboarding')) {
//           return '/home';
//         }
//         return null;
//       }

//       // 3. LOGGED OUT LOGIC
//       if (!AuthState.isLoggedIn) {
//         if (location != '/login' &&
//             location != '/register' &&
//             !location.startsWith('/onboarding')) {
//           return '/login';
//         }
//       }

//       return null;
//     },
//     routes: [
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
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return RegisterScreen(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingGender',
//         name: 'onboarding_gender',
//         builder: (context, state) => const OnboardingGender(),
//       ),
//       GoRoute(
//         path: '/onboardingHeight',
//         name: 'onboarding_height',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return HeightScreen(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingBirthdate',
//         name: 'onboarding_birthdate',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return BirthDateScreen(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingWeight',
//         name: 'onboarding_weight',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return WeightScreen(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingGoal',
//         name: 'onboarding_goal',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return OnboardingGoal(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingAllset',
//         name: 'onboarding_allset',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return AllSet(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingPlan',
//         name: 'onboarding_plan',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return Plan(userModel:extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingNotifications',
//         name: 'onboarding_notifications',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return NotificationPermissionPage(userModel: extra);
//         },
//       ),

//       GoRoute(
//         path: '/onboardingAllergies',
//         name: 'onboarding_allergies',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return Allergies(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/onboardingGoalWeight',
//         name: 'onboarding_goal_weight',
//         builder: (context, state) {
//           final extra = state.extra as UserModel?;
//           return GoalWeightScreen(userModel: extra);
//         },
//       ),
//       GoRoute(
//         path: '/paymentApplication',
//         name: 'payment_application',
//         builder: (context, state) {
//           return PaymentApplication();
//         },
//       ),
//       GoRoute(
//         path: '/creditCardInfo',
//         name: 'creditCardInfo',
//         builder: (context, state) => const Creditcardinfo(),
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
//       GoRoute(
//         path: '/trialSubscriptionPage',
//         name: 'trial_subscription_page',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: TrialSubscriptionPage()),
//       ),
//       GoRoute(
//         path: '/weeklyBreakdownScreen',
//         name: 'WeeklyBreakdownScreen',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: WeeklyBreakdownScreen()),
//       ),
//       GoRoute(
//         path: '/log',
//         name: 'log',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: DatabaseSearch()),
//       ),

//       GoRoute(
//         path: '/streak',
//         name: 'streak',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: StreakScreen()),
//       ),
//       ShellRoute(
//         builder: (context, state, child) {
//           return ScaffoldWithBottomNavBar(child: child);
//         },
//         routes: [
//           GoRoute(
//             path: '/home',
//             name: 'home',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: HomeScreen()),
//           ),
//           GoRoute(
//             path: '/log_food',
//             name: 'log_food',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: LogFood()),
//           ),

//           GoRoute(
//             path: '/progress',
//             name: 'progress',
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: ProgressPage()),
//           ),
//           GoRoute(
//             path: '/settings',
//             name: 'settings',
//             pageBuilder: (context, state) =>
//                 NoTransitionPage(child: SettingsScreen()),
//           ),
//         ],
//       ),
//     ],
//     errorBuilder: (context, state) =>
//         Scaffold(body: Center(child: Text('Error: ${state.error}'))),
//   );
// }

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
//   void goToNotifications() => go('/notifications');
//   void goToSettings() => go('/settings');
//   void goToProfile() => go('/profile');
//   void goToStreak() => go('/streak');

//   void logout() {
//     AuthState.isLoggedIn = false;
//     AuthState.isRegistered = false;
//     AuthState.finishedOnboarding = false;
//     go('/login');
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/view/custom _widget/custom_navbar.dart';
import 'package:graduation_project/view/screens/auth/sign_in_screen.dart';
import 'package:graduation_project/view/screens/auth/register_screen.dart';
import 'package:graduation_project/view/screens/database/database_search.dart';
import 'package:graduation_project/view/screens/home/badges.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';
import 'package:graduation_project/view/screens/home/log_food.dart';
import 'package:graduation_project/view/screens/home/notifications_settings_screen.dart';
import 'package:graduation_project/view/screens/home/profile_screen.dart';
import 'package:graduation_project/view/screens/notifications/notifications_screen.dart';
import 'package:graduation_project/view/screens/onboarding/allergies.dart';
import 'package:graduation_project/view/screens/onboarding/allset.dart';
import 'package:graduation_project/view/screens/onboarding/birthdate_screen.dart';
import 'package:graduation_project/view/screens/onboarding/goalWeight.dart';
import 'package:graduation_project/view/screens/onboarding/notification_permission.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_gender.dart';
import 'package:graduation_project/view/screens/onboarding/onboarding_goal.dart';
import 'package:graduation_project/view/screens/onboarding/screen_height.dart';
import 'package:graduation_project/view/screens/onboarding/screen_weight.dart';
import 'package:graduation_project/view/screens/payment/creditcardinfo.dart';
import 'package:graduation_project/view/screens/payment/payment_application.dart';
import 'package:graduation_project/view/screens/plan/plan.dart';
import 'package:graduation_project/view/screens/progress/progress.dart';
import 'package:graduation_project/view/screens/progress/weekly_breakdown_screen.dart';
import 'package:graduation_project/view/screens/progress/weekly_progress.dart';
import 'package:graduation_project/view/screens/settings/settings_screen.dart';
import 'package:graduation_project/view/screens/splash/splash.dart';
import 'package:graduation_project/view/screens/onboarding/trialsubscriptionpage.dart';
import 'package:graduation_project/view/screens/home/scanner.dart';
import 'package:graduation_project/view/screens/streak/streak_screen.dart';
import 'package:graduation_project/view/screens/settings/goals_screen.dart';
import 'package:graduation_project/view/screens/plan/premium_plan.dart';
 
// Simple in-memory auth state — splash screen sets this on startup
class AuthState {
  static bool isLoggedIn = false;
  static bool isRegistered = false;
  static bool finishedOnboarding = false;
  static bool hasSeenSplash = false;
}
 
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
 
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
 
    // ── SIMPLE REDIRECT ────────────────────────────────────────────────────
    // Only guard /home: if not logged in, send to /login.
    // Everything else (onboarding, register, login, splash) is freely accessible.
    // The splash screen is the single place that decides where to send the user.
    redirect: (context, state) {
      final location = state.matchedLocation;
 
      // Always allow splash — it handles its own routing
      if (location == '/splash') return null;
 
      // Only block /home and app routes from unauthenticated users
      final protectedRoutes = ['/home', '/log_food', '/progress', '/settings',
        '/profile', '/notifications', '/notificationsScreen', '/foodScanner',
        '/log', '/streak', '/weeklyBreakdownScreen', '/goals', '/premiumPlan'];
 
      if (protectedRoutes.contains(location) && !AuthState.isLoggedIn) {
        return '/login';
      }
 
      return null;
    },
    // ───────────────────────────────────────────────────────────────────────
 
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
 
      // ── ONBOARDING ROUTES (no auth required — user hasn't registered yet) ─
      GoRoute(
        path: '/onboardingGender',
        name: 'onboarding_gender',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return OnboardingGender(userModel: extra);
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
        path: '/onboardingHeight',
        name: 'onboarding_height',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return HeightScreen(userModel: extra);
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
        path: '/onboardingGoalWeight',
        name: 'onboarding_goal_weight',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return GoalWeightScreen(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingAllergies',
        name: 'onboarding_allergies',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return Allergies(userModel: extra);
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
        path: '/onboardingAllset',
        name: 'onboarding_allset',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return AllSet(userModel: extra);
        },
      ),
      GoRoute(
        path: '/onboardingPlan',
        name: 'onboarding_plan',
        builder: (context, state) {
          final extra = state.extra as UserModel?;
          return Plan(userModel: extra);
        },
      ),
      // ───────────────────────────────────────────────────────────────────────
 
      GoRoute(
        path: '/trialSubscriptionPage',
        name: 'trial_subscription_page',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: TrialSubscriptionPage()),
      ),
      GoRoute(
        path: '/paymentApplication',
        name: 'payment_application',
        builder: (context, state) {
          final planData = state.extra as Map<String, dynamic>?;
          return PaymentApplication(planData: planData);
        },
      ),
         GoRoute(
        path: '/badges',
        name: 'badges',
        builder: (context, state) => BadgesScreen(),
      ),
      GoRoute(
        path: '/creditCardInfo',
        name: 'creditCardInfo',
        builder: (context, state) {
          final planData = state.extra as Map<String, dynamic>?;
          return Creditcardinfo(planData: planData);
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
      GoRoute(
        path: '/weeklyBreakdownScreen',
        name: 'WeeklyBreakdownScreen',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: WeeklyBreakdownScreen()),
      ),
      GoRoute(
        path: '/log',
        name: 'log',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DatabaseSearch()),
      ),
      GoRoute(
        path: '/streak',
        name: 'streak',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: StreakScreen()),
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/premiumPlan',
        name: 'premiumPlan',
        builder: (context, state) => const PremiumPlanScreen(),
      ),
 
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/log_food',
            name: 'log_food',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LogFood()),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressPage()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
 
extension NavigationHelpers on BuildContext {
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToHome() => go('/home');
  void goToSettings() => go('/settings');
  void goToProfile() => go('/profile');
  void goToStreak() => go('/streak');
  void goToNotifications() => go('/notifications');
  void goToFoodScanner() => go('/foodScanner');
  void goToSubscription() => go('/subscription');
 
  void logout() {
    AuthState.isLoggedIn = false;
    AuthState.isRegistered = false;
    AuthState.finishedOnboarding = false;
    go('/login');
  }
}