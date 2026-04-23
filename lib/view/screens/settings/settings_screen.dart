// lib/view/screens/home/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
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
                  backgroundImage: AssetImage(
                    "assets/images/placeholder_profile.png",
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

            // Other settings title - matches first design spacing
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
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
                  // No dividers between items - exactly like first design
                  _buildTile(
                    context,
                    Icons.track_changes,
                    'My Target',
                    onTap: () {
                      // Navigate to target screen
                    },
                  ),
                  _buildTile(
                    context,
                    Icons.energy_savings_leaf,
                    'Your Premium',
                    onTap: () => context.push('/profile'),
                  ),
                  _buildTile(
                    context,
                    Icons.notifications_none,
                    'Notifications',
                    isLast: true,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
            ),

            // Extra spacing before subscription section
            const SizedBox(height: 20),

            //Logout Section
            // SettingsContainer(
            //   child: Column(
            //     children: [
            //       _buildTile(
            //         context,
            //         Icons.logout,
            //         'Log Out',
            //         iconColor: Colors.red,
            //         textColor: Colors.red,
            //         isLast: true,
            //         onTap: () => _showLogoutDialog(context),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.25, // 25% of screen height
            ),
            Center(child: _buildLogoutButton(onTap: () {})),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.5, // 150% line height
              letterSpacing: -0.011,
              color: Colors.white,
            ),
          ),
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
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
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
              onPressed: () async {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  await _authService.signOut();

                  if (context.mounted) Navigator.pop(context);

                  AuthState.isLoggedIn = false;
                  AuthState.isRegistered = false;

                  if (context.mounted) {
                    context.go('/login');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
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

class SettingsContainer extends StatelessWidget {
  final Widget child;
  const SettingsContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
