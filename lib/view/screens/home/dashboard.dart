// home_screen.dart (fixed version)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: Avatar + Text
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.go('/profile');
                          },
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(
                              'assets/images/placeholder_profile.png',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, Mohanad",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Remember why you started..",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff464646),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Side: Notifications + Streak
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          // go to notifications screen
                        },
                        icon: const Icon(
                          Icons.notifications,
                          size: 20,
                          color: Color(0xff210701),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            Image.asset('assets/images/streak.png', height: 18),
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

              const SizedBox(height: 30),

              // Horizontal date picker
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final days = [
                      "Sat",
                      "Sun",
                      "Mon",
                      "Tue",
                      "Wed",
                      "Thu",
                      "Fri",
                      "Sat",
                    ];
                    final dates = [11, 12, 13, 14, 15, 16, 17, 18];
                    List<Color> bgColors = [
                      const Color(0xFF4CAF50),
                      const Color(0xFFD90C0C),
                      const Color(0xFFFFC107),
                      const Color(0xFFD90C0C),
                      const Color(0xFF4CAF50),
                      const Color(0xFFFFC107),
                      const Color(0xFFD90C0C),
                      const Color(0xFF4CAF50),
                    ];

                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: bgColors[index],
                            child: Text(
                              dates[index].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            days[index],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff141414),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Progress Card with PageView
              SizedBox(
                height: 360,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    _buildProgressCard(size),
                    _buildProgressCard(
                      size,
                    ), // Second card (you can customize this)
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Page Indicator Dots
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

              const Text(
                "Recently Logged",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Recently Logged Food Cards
              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
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

  Widget _buildProgressCard(Size size) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 15),
              CircularPercentIndicator(
                radius: constraints.maxHeight * 0.25,
                lineWidth: 7,
                percent: 0.66,
                progressColor: const Color(0xffD90C0C),
                backgroundColor: Colors.grey.shade100,
                circularStrokeCap: CircularStrokeCap.round,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FittedBox(
                      child: Text(
                        "1600",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "of 2400",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
          );
        },
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20, bottom: 15, left: 10, top: 5),
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
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
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
                          fontSize: 17,
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
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Calories",
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Text(
                  "8:00am",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Macro circles
                Row(
                  children: [
                    _macroCircle(0.7, Colors.red),
                    const SizedBox(width: 8),
                    _macroCircle(0.4, Colors.black),
                    const SizedBox(width: 8),
                    _macroCircle(0.6, Colors.grey),
                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                        // Navigate to food details
                      },
                      child: Container(
                        width: 84,
                        height: 23,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Macro labels
                Row(
                  children: [
                    _macroLabel(Colors.red, "Protein 30g"),
                    const SizedBox(width: 15),
                    _macroLabel(Colors.black, "Carbs 10g"),
                    const SizedBox(width: 15),
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
      radius: 18,
      lineWidth: 6,
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
        const SizedBox(width: 5),
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
        Image.asset(img, height: 24),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
