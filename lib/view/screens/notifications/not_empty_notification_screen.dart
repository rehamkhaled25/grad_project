import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 25),
          const SectionHeader(title: "Today"),
          NotificationCard(
            text: "It's time for your Lunch – Don't forget to log your meal.",
            iconColor: const Color(0xFFFF5252),
          ),
          NotificationCard(
            text:
                "You're doing great! Try adding more fiber-rich foods to hit today's target.",
            iconColor: const Color(0xFFFF5252),
          ),
          NotificationCard(
            text: "You've hit 80% of your daily calorie goal—keep it going!",
            iconColor: const Color(0xFFFF5252),
          ),
          NotificationCard(
            text: "You've logged meals for 7 consecutive days",
            iconColor: const Color(0xFFFF5252),
          ),
          const SizedBox(height: 30),
          const SectionHeader(title: "Earlier"),
          NotificationCard(
            text: "Consider a light snack to help maintain your energy levels.",
            iconColor: const Color(0xFF323232),
          ),
          NotificationCard(
            text:
                "Review your progress this week and celebrate your small wins!",
            iconColor: const Color(0xFF323232),
          ),
          NotificationCard(
            text:
                "Plan your dinner ahead—choosing healthier options can be fun!",
            iconColor: const Color(0xFF323232),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String text;
  final Color iconColor;

  const NotificationCard({
    super.key,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black.withOpacity(0.65), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
