// lib/view/screens/home/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            const SettingsContainer(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://www.figma.com/design/KcSXH4dDp2s9FhLW5wigQp/Board?node-id=1660-8127&m=dev&t=oEDSrgyXE3uuGavc-1',
                  ),
                ),
                title: Text(
                  'Moe_Hany',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'Male / Maintain Weight',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                'Other settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Account Settings Section
            SettingsContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 25, bottom: 10),
                    child: Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildTile(
                    context,
                    Icons.person_outline,
                    'Profile Data',
                    onTap: () {
                      // Navigate to profile data screen
                      context.go('/profile');
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.track_changes,
                    'My Target',
                    onTap: () {
                      // Navigate to target screen
                      // context.go('/onboardingGoal');
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.cloud_upload_outlined,
                    'Syncing and Backup',
                    onTap: () {
                      // Navigate to sync settings
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.notifications_none,
                    'Notifications',
                    isLast: true,
                    onTap: () {
                      // Navigate to notifications settings
                      context.go('/notifications');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subscription & Logout Section
            SettingsContainer(
              child: Column(
                children: [
                  _buildTile(
                    context,
                    Icons.credit_card,
                    'Manage subscription Plan',
                    onTap: () {
                      // Navigate to subscription
                      // context.go('/subscription');
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.logout,
                    'Log Out',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    isLast: true,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
    Color? textColor,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.black),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap:
              onTap ??
              () {
                // Default behavior if no onTap provided
                debugPrint('Navigating to $title');
              },
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 65, right: 16),
            child: Divider(height: 1, thickness: 1, color: Colors.grey),
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout
                Navigator.pop(context);

                // Update auth state
                AuthState.isLoggedIn = false;
                AuthState.isRegistered = false;

                // Navigate to login
                context.go('/login');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

// Custom Container Widget
class SettingsContainer extends StatelessWidget {
  final Widget child;
  const SettingsContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
