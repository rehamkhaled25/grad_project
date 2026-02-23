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
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavigation(
            image: 'assets/images/home.png',
            isSelected: selectedIndex == 0,
            onTap: () => setState(() => selectedIndex = 0),
             color: Color(0xff000000),
          ),
          BottomNavigation(
          image: 'assets/images/document.png',
            isSelected: selectedIndex == 1,
            onTap: () => setState(() => selectedIndex = 1),
             color: Color(0xff000000),
          ),
          BottomNavigation(
            image: 'assets/images/Scan.png',
            isSelected: selectedIndex == 2,
            onTap: () => setState(() => selectedIndex = 2),
             color: Color(0xff000000),
          ),
          BottomNavigation(
            image: 'assets/images/payment_icon.png',
            isSelected: selectedIndex == 3,
            onTap: () => setState(() => selectedIndex = 3),
            color: Color(0xff000000),
          ),
           BottomNavigation(
            image: 'assets/images/Setting.png',
            isSelected: selectedIndex == 4,
            onTap: () => setState(() => selectedIndex = 4),
            
            color: Color(0xff9B9B9B)
          ),
        ],
      ),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final String image;
final Color color;
  const BottomNavigation({
    super.key,
    required this.image,
    this.isSelected = false,
    required this.onTap,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30, 
      backgroundColor: isSelected ? Colors.black : const Color(0xffF5F5F5),
      child: GestureDetector(
        onTap: 
          onTap
        ,
        child: Image(image: AssetImage(image),
        color: isSelected?Colors.white: color,
        ))
    );
  }
}
