import 'package:flutter/material.dart';
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
                  CircleAvatar(
                    radius: width * 0.05,
                    backgroundImage: const AssetImage(
                        'assets/images/placeholder_profile.png'),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_back_ios,
                      color: const Color(0xffD9D9D9),
                      size: width * 0.04),
                  SizedBox(width: width * 0.02),
                  Text(
                    '14 December',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Icon(Icons.arrow_forward_ios,
                      color: const Color(0xffD9D9D9),
                      size: width * 0.04),
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

class MealCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const MealCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Container(
      width: double.infinity,
      height: height * 0.13,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: width * 0.08),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/flame bta3et saf7et el database.png',
                  color: const Color(0xffB3B3B3),
                  height: 16,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xffB3B3B3),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const AddFoodButton(),
              ],
            ),
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
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Container(
      width: double.infinity,
      height: height * 0.13,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Snack",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Image.asset('assets/images/boba.png', height: 30),
              SizedBox(width: width * 0.03),
              // Expanded here prevents the "Boba Tea" text from pushing the column off screen
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Boba Tea",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "1 cup",
                      style: TextStyle(fontSize: 12, color: Color(0xffB3B3B3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), 
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/flame bta3et saf7et el database.png',
                        color: const Color(0xffB3B3B3),
                        height: 14,
                      ),
                      const Text(
                        " 300",
                        style: TextStyle(fontSize: 12, color: Color(0xffB3B3B3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const AddFoodButton(),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xffF2F2F2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 2,
          )
        ],
      ),
      child: const Text(
        "Add food",
        style: TextStyle(
          color: Color(0xffD90C0C),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}