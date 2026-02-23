// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  // Map indices to routes
  final List<String> _routes = [
    '/home',
    '/documents',
    '/foodScanner',
    '/notifications',
    '/settings',
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateSelectedIndex();
      }
    });
  }

  void _updateSelectedIndex() {
    try {
      // Get the current route location using the router's state
      final router = GoRouter.of(context);
      final String location = router.routeInformationProvider.value.uri
          .toString();

      if (location.startsWith('/home')) {
        selectedIndex = 0;
      } else if (location.startsWith('/documents')) {
        selectedIndex = 1;
      } else if (location.startsWith('/foodScanner')) {
        selectedIndex = 2;
      } else if (location.startsWith('/notifications')) {
        selectedIndex = 3;
      } else if (location.startsWith('/settings')) {
        selectedIndex = 4;
      }

      // Only update if the widget is still mounted
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error updating selected index: $e');
    }
  }

  void _onItemTapped(int index) {
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });

      // Navigate to the selected route
      try {
        context.go(_routes[index]);
      } catch (e) {
        debugPrint('Navigation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe way to update index based on route changes
    try {
      _updateSelectedIndex();
    } catch (e) {
      // If error occurs, keep current selectedIndex
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomNavigationItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            BottomNavigationItem(
              icon: Icons.description,
              label: 'Docs',
              isSelected: selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            BottomNavigationItem(
              icon: Icons.document_scanner,
              label: 'Scan',
              isSelected: selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            BottomNavigationItem(
              icon: Icons.notifications,
              label: 'Alerts',
              isSelected: selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            BottomNavigationItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final IconData icon;
  final String label;

  const BottomNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isSelected
                ? Colors.black
                : const Color(0xffF5F5F5),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
