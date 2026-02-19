import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double weightKg = 70;
  bool isKg = true;

  final ScrollController _scrollController = ScrollController();

  double get weightLb => weightKg * 2.20462;

  @override
  void initState() {
    super.initState();
    // Initialize scroll to match initial weight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo((weightKg - 50) * 40); // 40 px per kg
    });
  }

  void onScroll() {
    double offset = _scrollController.offset;
    setState(() {
      weightKg = (50 + offset / 40).clamp(50, 95); // convert offset → kg
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          const CustomAppbar(currentStep: 4, totalSteps: 7),
          const SizedBox(height: 20),

          // Title
          const Text(
            "What's your current weight?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          // Weight display
          Center(
            child: RichText(
              text: TextSpan(
                children: isKg
                    ? [
                        TextSpan(
                          text: "${weightKg.toInt()} ",
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "kg",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ]
                    : [
                        TextSpan(
                          text: weightLb.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: " lb",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: () => setState(() => isKg = !isKg),
            child: Text(
              "tap to switch to ${isKg ? "lb" : "kg"}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 30),

          // Scrollable ruler
          SizedBox(
            height: 100,
            width: screenWidth,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                onScroll();
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 46,
                itemBuilder: (context, index) {
                  int kgValue = 50 + index;
                  bool isMajor = kgValue % 5 == 0;
                  return Container(
                    width: 40,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: isMajor ? 35 : 18,
                          width: 2,
                          color: Colors.black,
                        ),
                        if (isMajor) ...[
                          const SizedBox(height: 5),
                          Text(
                            "$kgValue",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Continue button
          InkWell(
            onTap: () {
              context.push('/onboardingGoal');
            },
            child: Container(
              height: 55,
              width: 360,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
