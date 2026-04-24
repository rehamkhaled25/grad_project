import 'package:flutter/material.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';

// Assuming your dashboard/bar import is here
// import 'package:graduation_project/view/screens/home/dashboard.dart';

class LogFood extends StatelessWidget {
  const LogFood({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: size.height * 0.02,
          ),
          children: [
            
            Row(
              children: [
                CircleAvatar(
                  
                  backgroundImage: const AssetImage(
                    'assets/images/placeholder_profile.png',
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_back_ios, color: const Color(0xffD9D9D9), size: width * 0.04),
                const SizedBox(width: 8),
                Text(
                  '14 December',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: const Color(0xffD9D9D9), size: width * 0.04),
                const Spacer(),
                SizedBox(width: width * 0.1),
              ],
            ),
            const SizedBox(height: 25),
            
            // RESTORED: Days of the week bar
            const DaysOfWeekBar(), 
            
            const SizedBox(height: 25),
            
           
            DailyProgressCard(size: size),
            
            const SizedBox(height: 30),
            
            
            const MealCard(title: "Breakfast", subtitle: "270 calories advised"),
            const SizedBox(height: 15),
            const MealCard(title: "Lunch", subtitle: "270 calories advised"),
            const SizedBox(height: 15),
            const MealCard(title: "Dinner", subtitle: "270 calories advised"),
            const SizedBox(height: 15),
            
            const SnackCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class DailyProgressCard extends StatelessWidget {
  final Size size;
  const DailyProgressCard({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Today’s Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("On Track", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Circular Progress Section
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size.width * 0.35,
                width: size.width * 0.35,
                child: const CircularProgressIndicator(
                  value: 0.66,
                  strokeWidth: 5,
                  backgroundColor: Color(0xffEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffD90C0C)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  SizedBox(
                    width: size.width * 0.28,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("1600", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Text("of 2400", style: TextStyle(color: Colors.black, fontSize: 10)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          
          // Stats Row with your Flame Asset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('assets/images/flame bta3et saf7et el database.png', "400", "Burned"),
              _buildStat('assets/images/target.png', "800", "Remaining"),
              _buildStat('assets/images/chart.png', "66.6%", "Progress"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String assetPath, String value, String label) {
    return Column(
      children: [
        Image.asset(assetPath, height: 20, color: Colors.black),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const MealCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding handles the height instead of a fixed value
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(
                'assets/images/flame bta3et saf7et el database.png',
                color: const Color(0xffB3B3B3),
                height: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const AddFoodButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class SnackCard extends StatelessWidget {
  const SnackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Snack", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Image.asset('assets/images/boba.png', height: 35),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text("Boba Tea", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text("1 cup", style: TextStyle(color: Colors.grey, fontSize: 12)),
                       SizedBox(width:10),
                      Image.asset(
                        'assets/images/flame bta3et saf7et el database.png',
                        color: const Color(0xffB3B3B3),
                        height: 14,
                      ),
                      const Text(" 300", style: TextStyle(color: Color(0xffB3B3B3), fontSize: 12)),
                   
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Row(
                  //   children: [
                  //     Image.asset(
                  //       'assets/images/flame bta3et saf7et el database.png',
                  //       color: const Color(0xffB3B3B3),
                  //       height: 14,
                  //     ),
                  //     const Text(" 300", style: TextStyle(color: Color(0xffB3B3B3), fontSize: 12)),
                  //   ],
                  // ),
                  const SizedBox(height: 8),
                  const AddFoodButton(),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class AddFoodButton extends StatelessWidget {
  const AddFoodButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xffF2F2F2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: const Text(
        "Add food",
        style: TextStyle(color: Color(0xffD90C0C), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}