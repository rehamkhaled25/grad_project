import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        // The scroll view must wrap everything inside the body
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Provides the iOS-style stretch
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "skip",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Text(
                  "How your trial 7-day free\ntrial works",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display', // Ensure your pubspec has this font
                  ),
                ),

                const SizedBox(height: 30),

                // This is the vertical timeline section from your UI
                const TrialTimeline(),

                const SizedBox(height: 40),

                // 1 Month Plan Card
                const PlanCard(
                  title: "1 Month",
                  price: "\$8.00 / MO",
                ),

                const SizedBox(height: 20),

                // 12 Month Popular Plan Card
                const PlanCard(
                  title: "12 Month",
                  price: "\$4.99 / MO",
                  subPrice: "\$95.88 \$59.99",
                  isPopular: true,
                ),

                // LARGE SPACE: To ensure the button is "below the fold"
                const SizedBox(height: 100),

                ContinueButton(
                  txt: "Continue",
                  onPressed: () {
                    // Your navigation logic
                  },
                ),

                // Bottom padding so the button isn't touching the edge after scrolling
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Minimal implementation of the timeline in your image
class TrialTimeline extends StatelessWidget {
  const TrialTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _timelineItem(Icons.check, "Complete Sign-up", true, true),
        _timelineItem(Icons.lock_outline, "Today: Get instant Access", true, true),
        _timelineItem(Icons.notifications_none, "Day 5: Get Trial Reminder", true, false),
        _timelineItem(Icons.favorite_border, "Day 7: Trial Ends", false, false),
      ],
    );
  }

  Widget _timelineItem(IconData icon, String text, bool showLine, bool isCompleted) {
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 40),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.black : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              if (showLine)
                Expanded(
                  child: VerticalDivider(
                    color: isCompleted ? Colors.black : Colors.grey.shade400,
                    thickness: 3,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? subPrice;
  final bool isPopular;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    this.subPrice,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (subPrice != null)
                    Text(subPrice!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -12,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Popular",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String txt;
  const ContinueButton({
    super.key,
    required this.onPressed,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          txt,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}