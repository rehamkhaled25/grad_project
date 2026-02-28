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

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(
                                'assets/images/placeholder_profile.png'),
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
                                    fontWeight: FontWeight.bold),
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
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
                            Image.asset('assets/images/streak.png',
                                height: 18),
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

              const SizedBox(height: 20),

              /// DAYS BAR
              const DaysOfWeekBar(),

              const SizedBox(height: 20),

              /// PAGEVIEW
              SizedBox(
                height: 360,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    DailyProgressCard(size: size),
                    DailyProgressCard(size: size),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// DOTS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics:
                      const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) =>
                      const FoodCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// DAYS OF WEEK BAR
////////////////////////////////////////////////////////////

class DaysOfWeekBar extends StatelessWidget {
  const DaysOfWeekBar({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      "Sat","Sun","Mon","Tue","Wed","Thu","Fri","Sat"
    ];
    final dates = [11,12,13,14,15,16,17,18];

    List<Color> bgColors = [
      const Color(0xFF4CAF50),
      const Color(0xFFD90C0C),
      const Color(0xFFFFC107),
      const Color(0xFFD90C0C),
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFD90C0C),
      const Color(0xFF4CAF50)
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(8, (index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: bgColors[index],
              child: Text(
                dates[index].toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              days[index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}

////////////////////////////////////////////////////////////
/// DAILY PROGRESS CARD (RESPONSIVE VERSION)
////////////////////////////////////////////////////////////

class DailyProgressCard extends StatelessWidget {
  final Size size;
  const DailyProgressCard({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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
                progressColor:
                    const Color(0xffD90C0C),
                backgroundColor:
                    Colors.grey.shade100,
                circularStrokeCap:
                    CircularStrokeCap.round,
                center: const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        "1600",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "of 2400",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  ProgressItem(
                      img:
                          'assets/images/bultorone fireee.png',
                      label: "400\nBurned"),
                  ProgressItem(
                      img:
                          'assets/images/target.png',
                      label: "800\nRemaining"),
                  ProgressItem(
                      img:
                          'assets/images/chart.png',
                      label: "66.6%\nProgress"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FOOD CARD
////////////////////////////////////////////////////////////

class FoodCard extends StatelessWidget {
  const FoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(
          right: 20, bottom: 15, left: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(25)),
            child: Image.asset(
              'assets/images/food log.png',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "Power Breakfast Bowl",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PROGRESS ITEM
////////////////////////////////////////////////////////////

class ProgressItem extends StatelessWidget {
  final String img;
  final String label;

  const ProgressItem({
    super.key,
    required this.img,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(img, height: 24),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}