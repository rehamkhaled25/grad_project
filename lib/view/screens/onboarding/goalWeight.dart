import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/view/custom _widget/custom_appBar.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';

class GoalWeightScreen extends StatefulWidget {
  final UserModel? userModel;
  const GoalWeightScreen({super.key, this.userModel});

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  double weightKg = 65.0;
  bool isKg = true;
  final ScrollController _scrollController = ScrollController();

  final double itemWidth = 10.0;
  final int minWeightKg = 40;
  final int maxWeightKg = 160;

  double kgToLb(double kg) => kg * 2.20462;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToValue(weightKg);
    });
  }

  void _scrollToValue(double value) {
    if (_scrollController.hasClients) {
      double offset = (value - minWeightKg) * (itemWidth * 10);
      _scrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _continueToNextPage() {
    final currentModel = widget.userModel ?? UserModel();
  final updatedUser = currentModel.copyWith(goalWeight: weightKg);
    context.push('/onboardingAllergies',extra: updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double displayWeight = isKg ? weightKg : kgToLb(weightKg);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppbar(currentStep: 6, totalSteps: 9),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "What is your goal weight?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),

          // Precisely positioning the weight display relative to the UI image
          const Spacer(flex: 3),

          Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${displayWeight.toInt()} ",
                      style: const TextStyle(
                        fontSize: 47,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff605A5A),
                      ),
                    ),
                    TextSpan(
                      text: isKg ? "kg" : "lb",
                      style: const TextStyle(
                        fontSize: 47,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff605A5A),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                // Aligns "swipe for lbs" under the 'kg/lb' unit text
                padding: const EdgeInsets.only(left: 60),
                child: GestureDetector(
                  onTap: () => setState(() => isKg = !isKg),
                  child: Text(
                    "swipe for ${isKg ? "lbs" : "kg"}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Horizontal Ruler
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    double offset = _scrollController.offset;
                    setState(() {
                      weightKg = (minWeightKg + offset / (itemWidth * 10))
                          .clamp(
                            minWeightKg.toDouble(),
                            maxWeightKg.toDouble(),
                          );
                    });
                    return true;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 2),
                    itemCount: (maxWeightKg - minWeightKg) * 10 + 1,
                    itemBuilder: (context, index) {
                      double currentKgValue = minWeightKg + (index / 10);
                      bool isMajor = index % 10 == 0;
                      bool isFive = index % 5 == 0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: itemWidth,
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: isMajor ? 45 : (isFive ? 30 : 20),
                              width: 1.5,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          if (isMajor)
                            Positioned(
                              top: 55,
                              left: -20,
                              right: -20,
                              child: Text(
                                isKg
                                    ? "${currentKgValue.toInt()}"
                                    : "${kgToLb(currentKgValue).toInt()}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    height: 50,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: ContinueButton(
              onPressed: _continueToNextPage,
              txt: "Continue",
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }
}
