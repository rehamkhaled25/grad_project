import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> with SingleTickerProviderStateMixin {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  int streakCount = 0;
  int longestStreak = 0;
  bool streakActive = false;
  bool _isLoading = true;
  int totalDaysLogged = 0;

  List<DateTime> loggedDays = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadStreakData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    try {
      final data = await FoodService().getStreak();
      if (mounted) {
        setState(() {
          streakCount = data['streak_count'] ?? 0;
          longestStreak = data['longest_streak'] ?? 0;
          streakActive = data['is_active'] ?? false;
          totalDaysLogged = data['total_days_logged'] ?? 0;

          final days = data['logged_days'] as List? ?? [];
          loggedDays = days
              .map((d) => DateTime.tryParse(d.toString()))
              .whereType<DateTime>()
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool isLogged(DateTime day) {
    return loggedDays.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  String _weeksText() {
    final weeks = (longestStreak / 7).floor();
    if (weeks >= 1) return "You've kept it for $weeks week${weeks > 1 ? 's' : ''}";
    return "You've logged $longestStreak day${longestStreak > 1 ? 's' : ''} in a row";
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(focusedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// HEADER
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          "Streak",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STREAK INFO
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  streakActive ? "Keep Going" : "Start Logging!",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "$streakCount",
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: streakActive ? Colors.red : Colors.grey,
                                  ),
                                ),
                                const Text(
                                  "Day Streak!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: streakActive
                                ? ScaleTransition(
                                    scale: _animation,
                                    child: Image.asset(
                                      "assets/images/avocado_happy.png",
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/images/avocado_sad.png",
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MESSAGE BOX
                    if (longestStreak > 0)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/fest.png", height: 30),
                              const SizedBox(width: 8),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                  children: [
                                    const TextSpan(text: "This is your "),
                                    const TextSpan(
                                      text: "longest",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " streak yet!\n${_weeksText()}",
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    /// GRAY SECTION
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xffF3F3F3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          /// MONTH HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                monthName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        focusedDay = DateTime(
                                          focusedDay.year,
                                          focusedDay.month - 1,
                                        );
                                      });
                                    },
                                    child: const Icon(Icons.chevron_left),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        focusedDay = DateTime(
                                          focusedDay.year,
                                          focusedDay.month + 1,
                                        );
                                      });
                                    },
                                    child: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// CALENDAR CARD
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xffF3F3F3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: focusedDay,

                              headerVisible: false,

                              selectedDayPredicate: (day) =>
                                  isSameDay(selectedDay, day),

                              onDaySelected: (selected, focused) {
                                setState(() {
                                  selectedDay = selected;
                                  focusedDay = focused;
                                });
                              },

                              calendarStyle: const CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  if (isLogged(day)) {
                                    return Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${day.day}",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text("$totalDaysLogged days logged"),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.emoji_events, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text("${longestStreak}d best"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
