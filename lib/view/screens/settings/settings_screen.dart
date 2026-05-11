
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/onboarding_service.dart';
 
class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});
 
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
 
class _SettingsScreenState extends State<SettingsScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  final ApiService _apiService = ApiService();
 
  Future<void> _performLogout() async {
    await _apiService.deleteToken();
 
   
    AuthState.isLoggedIn = false;
    AuthState.isRegistered = false;
    AuthState.finishedOnboarding = false;
 
    
    if (mounted) {
      context.go('/splash');
    }
  }
 
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
      body: FutureBuilder<UserModel?>(
        future: _onboardingService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text("Could not load profile. Please try again."),
            );
          }
          final user = snapshot.data!;
 
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsContainer(
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        "assets/images/placeholder_profile.png",
                      ),
                    ),
                    title: Text(
                      user.fullName ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff141414),
                      ),
                    ),
                    subtitle: Text(
                      '${user.gender ?? "N/A"} / ${user.goal ?? "N/A"}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(
                    'Account',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
 
                SettingsContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTile(
                        context,
                        Icons.track_changes,
                        'My Target',
                        onTap: () {},
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
 
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: _buildLogoutButton(
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
 
  Widget _buildLogoutButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Center(
          child: Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.5,
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
          color: textColor ?? const Color(0xff141414),
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () => context.pop(),
    );
  }
 
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(dialogContext);
 
                // Show a loading spinner while we clear data
                if (mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                }
 
                await _performLogout();
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