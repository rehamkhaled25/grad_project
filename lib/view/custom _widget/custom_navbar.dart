import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavigation(
            icon: Icons.home,
            isSelected: selectedIndex == 0,
            onTap: () => setState(() => selectedIndex = 0),
          ),
          BottomNavigation(
            icon: Icons.description,
            isSelected: selectedIndex == 1,
            onTap: () => setState(() => selectedIndex = 1),
          ),
          BottomNavigation(
            icon: Icons.document_scanner,
            isSelected: selectedIndex == 2,
            onTap: () => setState(() => selectedIndex = 2),
          ),
          BottomNavigation(
            icon: Icons.notifications,
            isSelected: selectedIndex == 3,
            onTap: () => setState(() => selectedIndex = 3),
          ),
           BottomNavigation(
            icon: Icons.settings,
            isSelected: selectedIndex == 4,
            onTap: () => setState(() => selectedIndex = 4),
          ),
        ],
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final IconData icon;

  const BottomNavigation({
    super.key,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30, 
      backgroundColor: isSelected ? Colors.black : const Color(0xffF5F5F5),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        iconSize: 33,
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
