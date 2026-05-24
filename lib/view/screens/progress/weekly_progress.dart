import 'package:flutter/material.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';

class WeeklyProgress extends StatefulWidget {
  const WeeklyProgress({super.key});

  @override
  State<WeeklyProgress> createState() => _WeeklyProgressState();
}

class _WeeklyProgressState extends State<WeeklyProgress> {
  int selectedIndex = 0;
  bool _isLoading = true;
  double _goalCal = 2000;

  List<Map<String, dynamic>> weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        FoodService().getWeeklyProgress().catchError((_) => <Map<String, dynamic>>[]),
        FoodService().getCaloriePlan().catchError((_) => <String, dynamic>{}),
      ]);

      final weekly = results[0] as List<Map<String, dynamic>>;
      final plan = results[1] as Map<String, dynamic>;
      _goalCal = (plan['calories'] ?? 2000).toDouble();

      final List<Map<String, dynamic>> data = [];
      for (final day in weekly) {
        final dateStr = day['date']?.toString() ?? '';
        final cal = (day['calories'] ?? 0).toDouble();
        final diff = cal - _goalCal;
        final pct = _goalCal > 0 ? (cal / _goalCal * 100) : 0.0;
        final maxBarWidth = 230.0;
        final barWidth = (pct / 100.0).clamp(0.0, 1.2) * maxBarWidth;

        DateTime? dt;
        try { dt = DateTime.parse(dateStr); } catch (_) {}

        data.add({
          "day": dt != null ? DateFormat('E').format(dt) : '?',
          "date": dt != null ? DateFormat('MMM d').format(dt) : dateStr,
          "cal": "${cal.toStringAsFixed(0)} cal",
          "diff": "${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(0)} cal",
          "proc": "${pct.toStringAsFixed(0)}%",
          "w": barWidth,
          "c": diff > 0 ? 0xffD90C0C : 0xff43A047,
        });
      }

      if (mounted) {
        setState(() {
          weeklyData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 24, color: Color(0xff151316)),
                    ),
                    const Text(
                      "Weekly Breakdown",
                      style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 48),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 3.335, backgroundColor: Color(0xff43A047)),
                      Text(
                        "  This Week",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff9291A5)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/spiral.png', color: Colors.black,),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Daily Goal", style: TextStyle(color: Color(0xff706B6B), fontSize: 10, fontWeight: FontWeight.w600)),
                          Text("${_goalCal.toStringAsFixed(0)} cal", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xffD9D9D9),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = 0),
                          child: selectedIndex == 0 
                            ? const CustomContainer(text: "Overview") 
                            : const Center(child: Text("Overview", style: TextStyle(fontWeight: FontWeight.w600))),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = 1),
                          child: selectedIndex == 1 
                            ? const CustomContainer(text: "Details") 
                            : const Center(child: Text("Details", style: TextStyle(fontWeight: FontWeight.w600))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), 

                // Scrollable List Section
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weeklyData.length,
                  itemBuilder: (context, index) {
                    final item = weeklyData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: CustomItem(
                        weekday: item['day'],
                        date: item['date'],
                        calories: item['cal'],
                        gainorloss: item['diff'],
                        percentage: item['proc'],
                        width: item['w'],
                        color: item['c'],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomContainer extends StatelessWidget {
  final String text;
  const CustomContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final double width;
  final String weekday;
  final String date;
  final String calories;
  final String gainorloss;
  final String percentage;
  final int color;

  const CustomItem({
    super.key,
    required this.width,
    required this.weekday,
    required this.date,
    required this.calories,
    required this.gainorloss,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekday, style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text(date, style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(calories, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
                      Text(gainorloss, style: TextStyle(fontSize: 14,color: Color(color), fontWeight: FontWeight.w600)),
                      Text(percentage, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 9.22,
                        decoration: BoxDecoration(
                          color: const Color(0xffEFEFEF),
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                      Container(
                        width: width,
                        height: 9.22,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }
}