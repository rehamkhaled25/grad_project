import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late Future<UserModel?> _userFuture;
  late Future<Map<String, dynamic>> _historyFuture;
  late Future<Map<String, dynamic>> _planFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getProfile();
    _historyFuture = FoodService().getFoodHistory().catchError((_) => <String, dynamic>{});
    _planFuture = FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{});
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
                            child: FutureBuilder<UserModel?>(
                              future: _userFuture,
                              builder: (context, snapshot) {
                                final imageUrl = snapshot.data?.profileImageUrl;
                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  return CircleAvatar(
                                    radius: 23.5,
                                    backgroundImage: NetworkImage(
                                      imageUrl.startsWith('http')
                                          ? imageUrl
                                          : '${ApiService.baseUrl}$imageUrl',
                                    ),
                                  );
                                }
                                return const CircleAvatar(
                                  radius: 23.5,
                                  backgroundImage: AssetImage(
                                    'assets/images/placeholder_profile.png',
                                  ),
                                );
                              },
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _planFuture,
                  builder: (context, planSnap) {
                    final plan = planSnap.data ?? {};
                    final dailyCal = (plan['calories'] ?? plan['daily_calories'] ?? 2400).toDouble();
                    final consumed = (plan['consumed'] ?? plan['calories_consumed'] ?? 0).toDouble();
                    final burned = (plan['burned'] ?? plan['calories_burned'] ?? 0).toDouble();
                    final remaining = (dailyCal - consumed).clamp(0, dailyCal);
                    final progress = dailyCal > 0 ? (consumed / dailyCal).clamp(0.0, 1.0) : 0.0;

                    final fats = (plan['fat'] ?? plan['fats'] ?? 0).toDouble();
                    final protein = (plan['protein'] ?? 0).toDouble();
                    final carbs = (plan['carbs'] ?? plan['carbohydrates'] ?? 0).toDouble();

                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      children: [
                        _DailyProgressCard(
                          size: size,
                          consumed: consumed,
                          dailyCal: dailyCal,
                          burned: burned,
                          remaining: remaining,
                          progress: progress,
                        ),
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
                                        center: Text(
                                          "${consumed.toStringAsFixed(0)}\nCalories",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
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
                                        "${fats.toStringAsFixed(0)}",
                                      ),
                                      const SizedBox(height: 5),
                                      _macroBreakdownLabel(
                                        Colors.red,
                                        "Protein",
                                        "${protein.toStringAsFixed(0)}",
                                      ),
                                      const SizedBox(height: 5),
                                      _macroBreakdownLabel(
                                        Colors.blue,
                                        "Carbs",
                                        "${carbs.toStringAsFixed(0)}",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
              FutureBuilder<Map<String, dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 350,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data = snapshot.data ?? {};
                  // Try to extract meals from various response shapes
                  final List meals = data['meals'] ?? data['logs'] ?? data['history'] ?? [];

                  if (meals.isEmpty) {
                    return SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) => const FoodCard(),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 350,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      physics: const BouncingScrollPhysics(),
                      itemCount: meals.length > 5 ? 5 : meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index] as Map<String, dynamic>;
                        return FoodCard(mealData: meal);
                      },
                    ),
                  );
                },
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

class _DailyProgressCard extends StatelessWidget {
  final Size size;
  final double consumed;
  final double dailyCal;
  final double burned;
  final double remaining;
  final double progress;

  const _DailyProgressCard({
    required this.size,
    required this.consumed,
    required this.dailyCal,
    required this.burned,
    required this.remaining,
    required this.progress,
  });

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
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                progress >= 0.8 ? "Almost There" : progress >= 0.5 ? "On Track" : "Getting Started",
                style: const TextStyle(
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
            percent: progress.toDouble(),
            progressColor: const Color(0xffD90C0C),
            backgroundColor: Colors.grey.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${consumed.toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "of ${dailyCal.toStringAsFixed(0)}",
                    style: const TextStyle(
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
            children: [
              ProgressItem(
                img: 'assets/images/bultorone fireee.png',
                label: "${burned.toStringAsFixed(0)}\nBurned",
              ),
              ProgressItem(
                img: 'assets/images/target.png',
                label: "${remaining.toStringAsFixed(0)}\nRemaining",
              ),
              ProgressItem(
                img: 'assets/images/chart.png',
                label: "${(progress * 100).toStringAsFixed(1)}%\nProgress",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final Map<String, dynamic>? mealData;
  const FoodCard({super.key, this.mealData});

  @override
  Widget build(BuildContext context) {
    final name = mealData?['food_name'] ?? mealData?['meal_name'] ?? mealData?['name'] ?? "Power Breakfast Bowl";
    final calories = mealData?['calories'] ?? mealData?['total_calories'] ?? 520;
    final time = mealData?['logged_at'] ?? mealData?['time'] ?? "8:00am";
    final proteinVal = mealData?['protein'] ?? mealData?['total_protein'] ?? 30;
    final carbsVal = mealData?['carbs'] ?? mealData?['total_carbs'] ?? 10;
    final fatsVal = mealData?['fat'] ?? mealData?['total_fat'] ?? 30;

    // Try to get an image URL from the meal data
    final imageUrl = mealData?['image_url'] ?? mealData?['food_image_url'];

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
            child: imageUrl != null
                ? Image.network(
                    imageUrl.toString().startsWith('http')
                        ? imageUrl.toString()
                        : '${ApiService.baseUrl}$imageUrl',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/food log.png',
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
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
                    Expanded(
                      child: Text(
                        "$name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${(calories is num) ? calories.toStringAsFixed(0) : calories}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
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
                Text(
                  "$time",
                  style: const TextStyle(
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
                    _macroLabel(Colors.red, "Protein ${proteinVal is num ? '${proteinVal.toStringAsFixed(0)}g' : proteinVal}"),
                    _macroLabel(Colors.black, "Carbs ${carbsVal is num ? '${carbsVal.toStringAsFixed(0)}g' : carbsVal}"),
                    _macroLabel(Colors.grey, "Fats ${fatsVal is num ? '${fatsVal.toStringAsFixed(0)}g' : fatsVal}"),
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