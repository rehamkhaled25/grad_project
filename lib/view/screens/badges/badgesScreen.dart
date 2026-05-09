import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/home/dashboard.dart';

class LogFood extends StatelessWidget {
  const LogFood({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: width * 0.05,
                      backgroundImage: const AssetImage(
                        'assets/images/placeholder_profile.png',
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_back_ios,
                    color: const Color(0xffD9D9D9),
                    size: width * 0.04,
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    '14 December',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xffD9D9D9),
                    size: width * 0.04,
                  ),
                  const Spacer(),
                  SizedBox(width: width * 0.1),
                ],
              ),

              SizedBox(height: height * 0.025),
              const DaysOfWeekBar(),

              SizedBox(height: height * 0.025),

              DailyProgressCard(size: size),

              SizedBox(height: height * 0.03),

              const MealCard(
                title: "Breakfast",
                subtitle: "270 calories recommended",
              ),
              SizedBox(height: height * 0.02),
              const MealCard(
                title: "Lunch",
                subtitle: "270 calories recommended",
              ),
              SizedBox(height: height * 0.02),
              const MealCard(
                title: "Dinner",
                subtitle: "270 calories recommended",
              ),
              SizedBox(height: height * 0.02),
              const SnackCard(),
              SizedBox(height: height * 0.04),
            ],
          ),
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
      height: size.height * 0.38,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Today's Progress",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "On Track",
                style: TextStyle(
                  color: Color(0xffD90C0C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size.width * 0.45,
                height: size.width * 0.45,
                child: CircularProgressIndicator(
                  value: 0.66,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xffD90C0C),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "1600",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "of 2400",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.local_fire_department, "400", "Burned"),
              _buildStatItem(Icons.adjust, "800", "Remaining"),
              _buildStatItem(Icons.show_chart, "66.6%", "Progress"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xffB3B3B3),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xffB3B3B3),
                    fontSize: 14,
                  ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Snack",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.local_cafe, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Boba Tea",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "1 cup",
                      style: TextStyle(fontSize: 12, color: Color(0xffB3B3B3)),
                    ),
                  ],
                ),
              ),
              const Text("300 ", style: TextStyle(color: Color(0xffB3B3B3))),
              const AddFoodButton(),
            ],
          ),
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
      ),
      child: InkWell(
        onTap: () {
          context.push("/log");
        },
        child: const Text(
          "Add food",
          style: TextStyle(
            color: Color(0xffD90C0C),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
