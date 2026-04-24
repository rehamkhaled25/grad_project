import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/custom_appBar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Plan extends StatelessWidget {
  const Plan({super.key});

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Match the clean background
      body: SafeArea(
        child: Column(
          children: [
           
            CustomAppbar(currentStep: 7, totalSteps: 8),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: pageWidth * 0.07),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      backgroundColor: Color(0xff0E683E),
                      radius: 12,
                      child: Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Congratulations,\nyour plan is ready!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "You should lose:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xff262626),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Lose 10 kg by October 31",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Daily recommendation",
                        style: TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.w600, 
                          color: Color(0xff141414)
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Using GridView for better spacing management
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1, // Adjusts the height/width ratio
                      children: const [
                        CustomItem(text1: "Calories", text2: "1699", percent: 1699 / 2000, color: 0xffF20D0D),
                        CustomItem(text1: "Carbs", text2: "177", percent: 177 / 200, color: 0xff2A00C3),
                        CustomItem(text1: "Protein", text2: "141", percent: 141 / 200, color: 0xff0E683E),
                        CustomItem(text1: "Fats", text2: "141", percent: 141 / 200, color: 0xffF17D11),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffE3E3E3),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Health score", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text("7/10", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.favorite_border, color: Color(0xff141414), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.7,
                                    minHeight: 8,
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff43A047)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
              padding: EdgeInsets.symmetric(horizontal: pageWidth * 0.002, vertical: 20),
              child: ContinueButton(
                onPressed: () {
                  //NAVIGATION
                }, 
                txt: "Let's get started!!",
              ),
            ), // Extra space for scrolling comfort
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final String text1;
  final int color;
  final double percent;
  final String text2;

  const CustomItem({
    required this.text1,
    required this.color,
    required this.percent,
    required this.text2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffE3E3E3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 14, color: Color(0xff141414)),
              const SizedBox(width: 6),
              Text(
                text1, 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: CircularPercentIndicator(
              radius: 38,
              lineWidth: 5,
              percent: percent,
              progressColor: Color(color),
              backgroundColor: Color(0xffC9C8C8),
              circularStrokeCap: CircularStrokeCap.round,
              center: Text(
                text2, 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}