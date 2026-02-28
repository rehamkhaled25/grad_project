import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
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
      bottomNavigationBar: BottomNavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Row ---
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

              const SizedBox(height: 15),
              const DaysOfWeekBar(),
              const SizedBox(height: 15),

              // --- PageView (Progress & Breakdown) ---
              SizedBox(
                height: 380,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    // Page 1: Daily Progress
                    DailyProgressCard(size: size),

                    // Page 2: Calories Breakdown (Maintained from your version)
                    Container(
                      margin: const EdgeInsets.all(10),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            const SizedBox(height: 30),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 1.0,
                                    progressColor: const Color(0xFFFF1744),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
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
                                    percent: 0.40,
                                    progressColor: const Color(0xFFFFAB40),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                  CircularPercentIndicator(
                                    radius: 68.5,
                                    lineWidth: 15.0,
                                    percent: 0.15,
                                    progressColor: const Color(0xFF40C4FF),
                                    backgroundColor: Colors.transparent,
                                    reverse: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  _macroBreakdownLabel(Colors.orange, "Fats", "410"),
                                  const SizedBox(height: 10),
                                  _macroBreakdownLabel(Colors.red, "Protein", "142"),
                                  const SizedBox(height: 10),
                                  _macroBreakdownLabel(Colors.blue, "Carbs", "340"),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Swiping Dots
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
                      color: _currentPage == index ? Colors.black : Colors.grey.shade300,
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

  Widget _macroBreakdownLabel(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: const TextStyle(color: Color(0xff9291A5), fontSize: 12)),
      ],
    );
  }
}

// --- CUSTOM WIDGET 1: Days of Week Bar ---
class DaysOfWeekBar extends StatelessWidget {
  const DaysOfWeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final dates = [11, 12, 13, 14, 15, 16, 17, 18];
    final bgColors = [
      const Color(0xFF4CAF50), const Color(0xFFD90C0C), const Color(0xFFFFC107),
      const Color(0xFFD90C0C), const Color(0xFF4CAF50), const Color(0xFFFFC107),
      const Color(0xFFD90C0C), const Color(0xFF4CAF50)
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(8, (index) {
          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: bgColors[index],
                child: Text(
                  dates[index].toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(days[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }
}

// --- CUSTOM WIDGET 2: Daily Progress Card ---
class DailyProgressCard extends StatelessWidget {
  final Size size;
  const DailyProgressCard({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Today's Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("On Track", style: TextStyle(color: Color(0xffD90C0C), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 25),
          CircularPercentIndicator(
            radius: 70,
            lineWidth: 7,
            percent: 0.66,
            progressColor: const Color(0xffD90C0C),
            backgroundColor: Colors.grey.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FittedBox(child: Text("1600", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
                Text("of 2400", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              ProgressItem(img: 'assets/images/bultorone fireee.png', label: "400\nBurned"),
              ProgressItem(img: 'assets/images/target.png', label: "800\nRemaining"),
              ProgressItem(img: 'assets/images/chart.png', label: "66.6%\nProgress"),
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
      width: 300,
      margin: const EdgeInsets.only(right: 20, bottom: 15, left: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.asset('assets/images/food log.png', height: 140, width: double.infinity, fit: BoxFit.cover),
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
                      child: Text("Power Breakfast Bowl", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17), overflow: TextOverflow.ellipsis),
                    ),
                    Column(
                      children: const [
                        Text("520", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Calories", style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Text("8:00am", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
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
                        // context.push('/food-details'); 
                      },
                      child: Container(
                        width: 95,
                        height: 28,
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                        child: const Center(
                          child: Text("View Details", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _macroLabel(Colors.red, "Protein 30g"),
                    const SizedBox(width: 12),
                    _macroLabel(Colors.black, "Carbs 10g"),
                    const SizedBox(width: 12),
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
      lineWidth: 4,
      percent: percent,
      progressColor: color,
      backgroundColor: Colors.grey.shade200,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _macroLabel(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black)),
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
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}