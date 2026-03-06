import 'package:flutter/material.dart';

class ServingsDatabase extends StatelessWidget {
  const ServingsDatabase({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: 10,
          ),
          children: [
            
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 24, color: Color(0xff151316)),
                ),
                const Text(" Back to database",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))
              ],
            ),
            const SizedBox(height: 30),
            
           
            Row(
              children: [
                const Image(
                  //add attributes later when i get the actual image from database
                  // width: 59,
                  // height: 59,
                  image: AssetImage('assets/images/Noodle_placeholder.png'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Noodles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        width: 137,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text("124 calories",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

           
            _buildWhiteCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Serving Size", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(" (1x100g)", style: TextStyle(fontSize: 10, color: Color(0xffBBBABA))),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("0.25g", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildRoundActionButton(Icons.remove, false),
                      const SizedBox(width: 12),
                      _buildRoundActionButton(Icons.add, true),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Macronutrient", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildNutrientRow("Protein", "8g"),
                  _buildNutrientRow("Carbs", "0g"),
                  _buildNutrientRow("Fats", "1g"),
                  const Divider(height: 30, color: Color(0xffE4E4E4)),
                  const Text("Nutrition Facts", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildNutrientRow("Fiber", "0g"),
                  _buildNutrientRow("Sugar", "0g"),
                  _buildNutrientRow("Sodium", "74mg"),
                  const Divider(height: 30, color: Color(0xffE4E4E4)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("View Full Nutrition Label", style: TextStyle(fontSize: 13, color: Color(0xffD90C0C))),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), 

            
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Log Details",
                      style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const CustomRow(leftText: "Log time", rightText: "Not Set"),
                  const CustomRow(leftText: "Meal", rightText: "Breakfast"),
                ],
              ),
            ),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: (){
                //navigate hena ya bibo
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Center(child: Text("Add food",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          
          Padding(
            padding: const EdgeInsets.only(right: 24), 
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundActionButton(IconData icon, bool isBlack) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isBlack ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        border: isBlack ? null : Border.all(color: const Color(0xffBBBABA)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        icon: Icon(icon, size: 18, color: isBlack ? Colors.white : Colors.black),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  final String leftText;
  final String rightText;
  const CustomRow({required this.leftText, required this.rightText, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(leftText, style: const TextStyle(fontSize: 13, color: Colors.black)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rightText, style: const TextStyle(fontSize: 13, color: Colors.black)),
              IconButton(
                padding: const EdgeInsets.only(left: 8), 
                constraints: const BoxConstraints(), 
                visualDensity: VisualDensity.compact,
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios, size: 12),
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
    );
  }
}