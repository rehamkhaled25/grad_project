import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';

class TrialSubscriptionPage extends StatefulWidget {
  const TrialSubscriptionPage({super.key});

  @override
  State<TrialSubscriptionPage> createState() => _TrialSubscriptionPageState();
}

class _TrialSubscriptionPageState extends State<TrialSubscriptionPage> {
  // 0 = 1 Month, 1 = 12 Month
  int selectedPlanIndex = 1; // default selected (Popular one)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text(
                  "How your trial 7-day free\ntrial works",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 40),

              // =======================
              // Timeline
              // =======================
              Column(
                children: const [
                  TimelineStep(
                    stepIndex: 0,
                    title: "Complete Sign-up",
                    isDone: true,
                    iconData: Icons.check,
                    isLast: false,
                  ),
                  TimelineStep(
                    stepIndex: 1,
                    title: "Today: Get instant Access",
                    isDone: false,
                    iconData: Icons.lock,
                    isLast: false,
                    isActive: true,
                  ),
                  TimelineStep(
                    stepIndex: 2,
                    title: "Day 5: Get Trial Reminder",
                    isDone: false,
                    iconData: Icons.notifications,
                    isLast: false,
                  ),
                  TimelineStep(
                    stepIndex: 3,
                    title: "Day 7: Trial Ends",
                    isDone: false,
                    iconData: Icons.favorite,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // =======================
              // Plans
              // =======================

              // 1 Month Plan
              PlanCard(
                title: "1 Month",
                price: "\$8.00 / MO",
                isPopular: false,
                isSelected: selectedPlanIndex == 0,
                onTap: () {
                  setState(() {
                    selectedPlanIndex = 0;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 12 Month Plan (Popular)
              PlanCard(
                title: "12 Month",
                price: "\$4.99 / MO",
                oldPrice: "\$95.88",
                newPrice: "\$59.99",
                isPopular: true,
                isSelected: selectedPlanIndex == 1,
                onTap: () {
                  setState(() {
                    selectedPlanIndex = 1;
                  });
                },
              ),

              const Spacer(),

              // =======================
              // Continue Button
              // =======================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (selectedPlanIndex == 0) {
                      debugPrint("Selected: 1 Month Plan");
                    } else {
                      debugPrint("Selected: 12 Month Plan");
                    }
                    // Set logged in after subscription
                    AuthState.isLoggedIn = true;
                    context.go('/home');
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// =======================
// Timeline Step Widget
// =======================
//

class TimelineStep extends StatelessWidget {
  final int stepIndex;
  final String title;
  final bool isDone;
  final IconData iconData;
  final bool isLast;
  final bool isActive;

  const TimelineStep({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.isDone,
    required this.iconData,
    required this.isLast,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Last two steps (index 2 and 3)
    final bool isFutureStep = stepIndex >= 2;

    // Background color for icon circle
    final Color iconBg = (isDone || isActive)
        ? Colors.black
        : const Color(0xffB9B7C0);

    // Icon color logic
    final Color iconColor = (isDone || isActive)
        ? Colors.white
        : isFutureStep
        ? const Color(0xff403D3D) // different color for last two
        : Colors.white;

    // Line color
    final Color lineColor = isDone || isActive
        ? Colors.black
        : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(child: Icon(iconData, size: 16, color: iconColor)),
            ),
            if (!isLast) Container(width: 4, height: 40, color: lineColor),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // always bold
              color: Colors.black,
              decoration: isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? oldPrice;
  final String? newPrice;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    this.oldPrice,
    this.newPrice,
    required this.isPopular,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected ? Colors.red : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(top: 12), // space for badge
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (oldPrice != null && newPrice != null)
                        Row(
                          children: [
                            Text(
                              oldPrice!,
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              newPrice!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Right side
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Popular Badge
          if (isPopular)
            Positioned(
              top: -12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Popular",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
