import 'package:flutter/material.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF3F3F3),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "Badges",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Featured",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                BadgeItem(icon: Icons.rocket_launch, title: "Active\nStarter"),
                BadgeItem(icon: Icons.access_time, title: "High\nAchiever"),
                BadgeItem(icon: Icons.menu_book, title: "Eager\nLearner", isLocked: true),
                BadgeItem(icon: Icons.auto_awesome, title: "Serious\nLearner", isLocked: true),
                BadgeItem(icon: Icons.flag, title: "Confident\nReader", isNew: true),
                BadgeItem(icon: Icons.shield, title: "Error\nPolice"),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              "Weekly Achievements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: const [
                BadgeItem(
                  icon: Icons.local_fire_department,
                  title: "Hot Week",
                  notificationCount: 1,
                  isDiamond: true,
                ),
                BadgeItem(
                  icon: Icons.eco,
                  title: "Super Week",
                  notificationCount: 2,
                  isDiamond: true,
                ),
                BadgeItem(
                  icon: Icons.local_fire_department,
                  title: "Super Week",
                  isLocked: true,
                  notificationCount: 3,
                  isDiamond: true,
                ),
                BadgeItem(
                  icon: Icons.bubble_chart,
                  title: "Super Week",
                  notificationCount: 4,
                  isDiamond: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLocked;
  final bool isNew;
  final int notificationCount;
  final bool isDiamond;

  const BadgeItem({
    super.key,
    required this.icon,
    required this.title,
    this.isLocked = false,
    this.isNew = false,
    this.notificationCount = 0,
    this.isDiamond = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipPath(
                clipper: HexagonClipper(isDiamond: isDiamond),
                child: Container(
                  width: 55,
                  height: 55,
                  color: isLocked ? Colors.grey.shade300 : Colors.black,
                  child: Icon(
                    icon,
                    color: isLocked ? Colors.white : Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ],
          ),
        ),


        if (isNew)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xffE23337),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "New",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),


        if (notificationCount > 0)
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xffE23337),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  notificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  final bool isDiamond;
  HexagonClipper({this.isDiamond = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    if (isDiamond) {

      path.moveTo(w * 0.5, 0);
      path.lineTo(w, h * 0.5);
      path.lineTo(w * 0.5, h);
      path.lineTo(0, h * 0.5);
    } else {

      path.moveTo(w * 0.5, 0);
      path.lineTo(w, h * 0.25);
      path.lineTo(w, h * 0.75);
      path.lineTo(w * 0.5, h);
      path.lineTo(0, h * 0.75);
      path.lineTo(0, h * 0.25);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}