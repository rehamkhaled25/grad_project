import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: '',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '',
        ),
      ],
    );
  }
}