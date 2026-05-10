import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: const CircleAvatar(
                              radius: 23.5,
                              backgroundImage: AssetImage(
                                'assets/images/placeholder_profile.png',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<UserModel?>(
                              future: _userFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading...",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  );
                                }

                                // Use the fullName from the database, fallback to "User"
                                final String displayName =
                                    snapshot.data?.fullName ?? "User";

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hello, $displayName",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff141414)),
                                    ),
                                    const Text(
                                      "Remember why you started..",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff464646),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () =>
                              context.push('/notificationsScreen'),
                          icon: const Icon(
                            Icons.notifications,
                            size: 20,
                            color: Color(0xff210701),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => context.push('/streak'),
                                child: Image.asset(
                                  'assets/images/streak.png',
                                  height: 18,
                                ),
                              ),
                              const Text(
                                " 48",
                                style: TextStyle(
                                  color: Color(0xffD9D9D9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 40),
              const DaysOfWeekBar(),
              const SizedBox(height: 30),

           

              SizedBox(
                height: 380,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    DailyProgressCard(size: size),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calories Breakdown',
                              style: TextStyle(
                                color: Color(0xff1E1B39),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 1.0,
                                    progressColor: const Color(0xFF0000FF),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                    circularStrokeCap: CircularStrokeCap.butt,
                                    center: const Text(
                                      "1600\nCalories",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 0.41,
                                    progressColor: Colors.white,
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 0.40,
                                    progressColor: const Color(0xFFFF0000),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 0.16,
                                    progressColor: Colors.white,
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 0.15,
                                    progressColor: const Color(0xFFFF9705),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              child: Column(
                                children: [
                                  _macroBreakdownLabel(
                                    Colors.orange,
                                    "Fats",
                                    "410",
                                  ),
                                  const SizedBox(height: 5),
                                  _macroBreakdownLabel(
                                    Colors.red,
                                    "Protein",
                                    "142",
                                  ),
                                  const SizedBox(height: 5),
                                  _macroBreakdownLabel(
                                    Colors.blue,
                                    "Carbs",
                                    "340",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _currentPage == index
                          ? Colors.black
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Recently Logged",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => const FoodCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroBreakdownLabel(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 3, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(color: Color(0xff9291A5), fontSize: 12),
        ),
      ],
    );
  }
}

class DaysOfWeekBar extends StatelessWidget {
  const DaysOfWeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final dates = [11, 12, 13, 14, 15, 16, 17, 18];
    final bgColors = [
      const Color(0xFF4CAF50),
      const Color(0xFFD90C0C),
      const Color(0xFFFFC107),
      const Color(0xFFD90C0C),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFD90C0C),
      const Color(0xFF4CAF50),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(8, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: bgColors[index],
                child: Text(
                  dates[index].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
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
      width: size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Today's Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "On Track",
                style: TextStyle(
                  color: Color(0xffD90C0C),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 64,
            lineWidth: 5,
            percent: 0.66,
            progressColor: const Color(0xffD90C0C),
            backgroundColor: Colors.grey.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "1600",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "of 2400",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              ProgressItem(
                img: 'assets/images/bultorone fireee.png',
                label: "400\nBurned",
              ),
              ProgressItem(
                img: 'assets/images/target.png',
                label: "800\nRemaining",
              ),
              ProgressItem(
                img: 'assets/images/chart.png',
                label: "66.6%\nProgress",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10, left: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.asset(
              'assets/images/food log.png',
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Power Breakfast Bowl",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      children: const [
                        Text(
                          "520",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Calories",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Text(
                  "8:00am",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _macroCircle(0.7, Colors.red),
                    const SizedBox(width: 8),
                    _macroCircle(0.4, Colors.black),
                    const SizedBox(width: 8),
                    _macroCircle(0.6, Colors.grey),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroLabel(Colors.red, "Protein 30g"),
                    _macroLabel(Colors.black, "Carbs 10g"),
                    _macroLabel(Colors.grey, "Fats 30g"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroCircle(double percent, Color color) {
    return CircularPercentIndicator(
      radius: 16,
      lineWidth: 5,
      percent: percent,
      progressColor: color,
      backgroundColor: Colors.grey.shade200,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _macroLabel(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ProgressItem extends StatelessWidget {
  final String img;
  final String label;
  const ProgressItem({super.key, required this.img, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(img, height: 22),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}