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
     
      body: SafeArea( 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pageWidth * 0.07),
          child: Column(
            children: [
              CustomAppbar(currentStep: 8, totalSteps: 8),
              
             
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const CircleAvatar(
                        backgroundColor: Color(0xff0E683E),
                        radius: 16,
                        child: Icon(Icons.check, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Congratulations,\nyour plan is ready!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "you should lose:",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 170,
                        height: 39, 
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: const Center(
                          child: Text(
                            "Lose 10 kg by October 31",
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Daily recommendation",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff141414)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                     const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomItem(text1: "Calories", text2: "1699", percent: 1699/2000, color: 0xffF20D0D),
                              CustomItem(text1: "Carbs", text2: "177", percent: 177/200, color: 0xff2A00C3),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomItem(text1: "Protein", text2: "141", percent: 141/200, color: 0xff0E683E),
                              CustomItem(text1: "Carbs", text2: "141", percent: 141/200, color: 0xffF17D11),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      // Health Score Box - Fixed height 71 preserved
                      Container(
                        width: 345,
                        height: 71, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xffD8D8D8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Health score", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text("7/10", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff141414))),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                 Image(image: AssetImage("assets/images/fluent_heart-pulse-32-regular.png")),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: 0.7, 
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff43A047),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // This extra space ensures the scroll view has room 
                      // before hitting the button
                      const SizedBox(height: 20), 
                    ],
                  ),
                ),
              ),
              
              // The Button stays outside the ScrollView so it's always visible at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ContinueButton(onPressed: () {}, txt: "Lets get started!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomItem preserved with height 132
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
      width: 150,
      height: 132, // Preserved
      decoration: BoxDecoration(
        color: const Color(0xffD8D8D8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Image(image: AssetImage("assets/images/flame icon.png")),
                const SizedBox(width: 8),
                Text(text1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            CircularPercentIndicator(
              radius: 30,
              lineWidth: 5,
              percent: percent,
              progressColor: Color(color),
              backgroundColor: const Color.fromARGB(255, 208, 205, 205),
              center: Text(text2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.edit, size: 14),
            )
          ],
        ),
      ),
    );
  }
}