import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/user_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime _selectedDate = DateTime.now();

  late Future<UserModel?> _userFuture;
  late Future<Map<String, dynamic>> _historyFuture;
  late Future<Map<String, dynamic>> _planFuture;
  late Future<Map<String, dynamic>> _streakFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getProfile();
    _historyFuture = FoodService().getFoodHistory().catchError((_) => <String, dynamic>{});
    _planFuture = FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{});
    _streakFuture = FoodService().getStreak().catchError((_) => <String, dynamic>{});
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
                                    'assets/images/profilee.png',
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
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _streakFuture,
                            builder: (context, snap) {
                              final streakCount = snap.data?['streak_count'] ?? 0;
                              final isActive = snap.data?['is_active'] ?? false;
                              return InkWell(
                                onTap: () => context.push('/streak'),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/streak.png',
                                      height: 18,
                                      color: isActive ? null : const Color(0xffD9D9D9),
                                    ),
                                    Text(
                                      " $streakCount",
                                      style: TextStyle(
                                        color: isActive ? const Color(0xffD90C0C) : const Color(0xffD9D9D9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FutureBuilder<List<dynamic>>(
                future: Future.wait([_planFuture, _historyFuture]),
                builder: (context, snapshot) {
                  final planData = snapshot.data?[0] ?? {};
                  final historyData = snapshot.data?[1] ?? {};
                  final totals = historyData is Map && (historyData as Map).containsKey('totals') && historyData['totals'] is Map
                      ? Map<String, dynamic>.from(historyData['totals'])
                      : <String, dynamic>{};
                  final dailyCal = (planData['calories'] ?? 2400).toDouble();
                  final consumed = (totals['calories'] ?? 0).toDouble();
                  return DaysOfWeekBar(
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    selectedDate: _selectedDate,
                    consumed: consumed,
                    dailyCal: dailyCal,
                  );
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 380,
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([_planFuture, _historyFuture]),
                  builder: (context, snapshot) {
                    final planData = snapshot.data?[0] ?? {};
                    final historyData = snapshot.data?[1] ?? {};
                    final totals = historyData['totals'] ?? {};

                    final dailyCal = (planData['calories'] ?? 2400).toDouble();
                    final consumed = (totals['calories'] ?? 0).toDouble();
                    final remaining = (dailyCal - consumed).clamp(0.0, dailyCal);
                    final progress = dailyCal > 0 ? (consumed / dailyCal).clamp(0.0, 1.0) : 0.0;

                    final fats = (totals['fats'] ?? 0).toDouble();
                    final protein = (totals['protein'] ?? 0).toDouble();
                    final carbs = (totals['carbs'] ?? 0).toDouble();

                    double totalMacros = fats + protein + carbs;
                    double fatPct = totalMacros > 0 ? fats / totalMacros : 0.0;
                    double proteinPct = totalMacros > 0 ? protein / totalMacros : 0.0;
                    double carbsPct = totalMacros > 0 ? carbs / totalMacros : 0.0;

                    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final progressLabel = isToday ? "Today's Progress" : "Progress of day ${_selectedDate.day}";

                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      children: [
                        _DailyProgressCard(
                          size: size,
                          consumed: consumed,
                          dailyCal: dailyCal,
                          remaining: remaining,
                          progress: progress,
                          title: progressLabel,
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
                                        progressColor: Colors.blue,
                                        backgroundColor: Colors.transparent,
                                        reverse: true,
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
                                        percent: (proteinPct + fatPct).clamp(0.0, 1.0),
                                        progressColor: Colors.red,
                                        backgroundColor: Colors.transparent,
                                        reverse: true,
                                      ),
                                      CircularPercentIndicator(
                                        radius: 68.5,
                                        lineWidth: 15.0,
                                        percent: fatPct.clamp(0.0, 1.0),
                                        progressColor: Colors.orange,
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
                                      _macroBreakdownLabel(Colors.orange, "Fats", "${fats.toStringAsFixed(0)}g"),
                                      const SizedBox(height: 5),
                                      _macroBreakdownLabel(Colors.red, "Protein", "${protein.toStringAsFixed(0)}g"),
                                      const SizedBox(height: 5),
                                      _macroBreakdownLabel(Colors.blue, "Carbs", "${carbs.toStringAsFixed(0)}g"),
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
              FutureBuilder<Map<String, dynamic>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data ?? {};
                  final List meals = data['meals'] ?? data['logs'] ?? [];

                  if (meals.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          itemCount: meals.length > 5 ? 5 : meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index] is Map ? Map<String, dynamic>.from(meals[index] as Map) : <String, dynamic>{};
                            return FoodCard(mealData: meal);
                          },
                        ),
                      ),
                    ],
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
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;
  final double consumed;
  final double dailyCal;

  const DaysOfWeekBar({
    super.key,
    required this.onDateSelected,
    required this.selectedDate,
    this.consumed = 0,
    this.dailyCal = 0,
  });

  Color _calorieDotColor() {
    if (dailyCal <= 0 || consumed <= 0) return Colors.grey.shade400;
    final diff = ((consumed - dailyCal) / dailyCal).abs();
    if (diff <= 0.05) return Colors.green;
    if (diff <= 0.15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> dateRange = List.generate(8, (index) => now.subtract(Duration(days: 7 - index)));

    final days = dateRange.map((d) => DateFormat('E').format(d)).toList();
    final dates = dateRange.map((d) => d.day).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(8, (index) {
          final isSelected = DateFormat('yyyy-MM-dd').format(dateRange[index]) == DateFormat('yyyy-MM-dd').format(selectedDate);
          return GestureDetector(
            onTap: () => onDateSelected(dateRange[index]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: isSelected ? _calorieDotColor() : Colors.grey.shade200,
                  child: Text(
                    dates[index].toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
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
            ),
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
  final double remaining;
  final double progress;
  final String title;

  const _DailyProgressCard({
    required this.size,
    required this.consumed,
    required this.dailyCal,
    required this.remaining,
    required this.progress,
    required this.title,
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
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                progress >= 0.8 ? "Almost There" : progress >= 0.5 ? "On Track" : "In Progress",
                style: const TextStyle(color: Color(0xffD90C0C), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 64,
            lineWidth: 5,
            percent: progress.clamp(0.0, 1.0),
            progressColor: const Color(0xffD90C0C),
            backgroundColor: Colors.grey.shade100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${consumed.toStringAsFixed(0)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text("of ${dailyCal.toStringAsFixed(0)}", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProgressItem(img: 'assets/images/bultorone fireee.png', label: "${consumed.toStringAsFixed(0)}\nConsumed"),
              ProgressItem(img: 'assets/images/target.png', label: "${remaining.toStringAsFixed(0)}\nRemaining"),
              ProgressItem(img: 'assets/images/chart.png', label: "${(progress * 100).toStringAsFixed(1)}%\nProgress"),
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
    final name = mealData?['food_name'] ?? mealData?['meal_name'] ?? "Meal";
    final calories = (mealData?['calories'] ?? 0).toDouble();
    final timestamp = mealData?['logged_at'] ?? mealData?['timestamp'] ?? "";
    final timeStr = timestamp.isNotEmpty ? DateFormat.jm().format(DateTime.parse(timestamp)) : "Logged";

    final proteinVal = (mealData?['protein'] ?? 0).toDouble();
    final carbsVal = (mealData?['carbs'] ?? 0).toDouble();
    final fatsVal = (mealData?['fats'] ?? 0).toDouble();
    final totalMacro = proteinVal + carbsVal + fatsVal;

    final imageUrl = mealData?['image_url'];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10, left: 5),
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
            child: imageUrl != null
                ? Image.network(
                    imageUrl.toString().startsWith('http') ? imageUrl : '${ApiService.baseUrl}$imageUrl',
                    height: 130, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset('assets/images/food.png', height: 130, width: double.infinity, fit: BoxFit.cover),
                  )
                : Image.asset('assets/images/food.png', height: 130, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("$name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                    Column(
                      children: [
                        Text("${calories.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text("Calories", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                      
                    ),
                  ],
                ),
                Text(timeStr, style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _macroCircle(totalMacro > 0 ? proteinVal / totalMacro : 0, Colors.red),
                    const SizedBox(width: 8),
                    _macroCircle(totalMacro > 0 ? carbsVal / totalMacro : 0, Colors.black),
                    const SizedBox(width: 8),
                    _macroCircle(totalMacro > 0 ? fatsVal / totalMacro : 0, Colors.grey),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: const Text("View Details", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroLabel(Colors.red, "Protein ${proteinVal.toStringAsFixed(0)}g"),
                    _macroLabel(Colors.black, "Carbs ${carbsVal.toStringAsFixed(0)}g"),
                    _macroLabel(Colors.grey, "Fats ${fatsVal.toStringAsFixed(0)}g"),
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
      radius: 16, lineWidth: 5,
      percent: percent.clamp(0.0, 1.0),
      progressColor: color, backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _macroLabel(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
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
        Image.asset(img, height: 22),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}