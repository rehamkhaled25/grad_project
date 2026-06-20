import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:intl/intl.dart';

class WeeklyBreakdownScreen extends StatefulWidget {
  const WeeklyBreakdownScreen({super.key});

  @override
  State<WeeklyBreakdownScreen> createState() => _WeeklyBreakdownScreenState();
}

class _WeeklyBreakdownScreenState extends State<WeeklyBreakdownScreen> {
  bool _isOverview = true; // true = Overview (charts), false = Details (list)
  bool _isLoading = true;

  // ─── Colors (from original WeeklyBreakdownScreen) ───
  static const Color darkBlueColor = Color(0xFF01436E);
  static const Color redColor = Color(0xFFD22F27);
  static const Color yellowColor = Color(0xFFFDC700);

  List<Map<String, dynamic>> _weeklyProgress = [];
  double _goalCal = 2000;
  double _goalProtein = 150;
  double _goalCarbs = 250;
  double _goalFats = 70;

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

      if (mounted) {
        setState(() {
          _weeklyProgress = weekly;
          _goalCal = (plan['calories'] ?? 2000).toDouble();
          _goalProtein = (plan['protein'] ?? 150).toDouble();
          _goalCarbs = (plan['carbs'] ?? 250).toDouble();
          _goalFats = (plan['fats'] ?? 70).toDouble();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Compile detailed list data dynamically from backend logs
  List<Map<String, dynamic>> get _compiledDetailsList {
    final List<Map<String, dynamic>> data = [];
    for (final day in _weeklyProgress) {
      final dateStr = day['date']?.toString() ?? '';
      final cal = (day['calories'] ?? 0).toDouble();
      final diff = cal - _goalCal;
      final pct = _goalCal > 0 ? (cal / _goalCal * 100) : 0.0;
      final maxBarWidth = 230.0;
      final barWidth = (pct / 100.0).clamp(0.0, 1.2) * maxBarWidth;

      DateTime? dt;
      try {
        dt = DateTime.parse(dateStr);
      } catch (_) {}

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
    return data;
  }

  String get _currentRangeStr {
    if (_weeklyProgress.isEmpty) return "Loading...";
    try {
      final firstDate = DateTime.parse(_weeklyProgress.first['date']);
      final lastDate = DateTime.parse(_weeklyProgress.last['date']);
      return "${DateFormat('MMM d').format(firstDate)} - ${DateFormat('MMM d, yyyy').format(lastDate)}";
    } catch (_) {
      return "This Week";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: 80,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _currentRangeStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : (_isOverview ? _buildOverview() : _buildDetails()),
    );
  }

  // ─── Overview (Charts) ───
  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildGoalCard(),
          const SizedBox(height: 25),
          _buildToggleSwitch(),
          const SizedBox(height: 25),
          _buildChartContainer(
            title: "Daily Calorie Intake",
            child: _buildBarChart(),
          ),
          const SizedBox(height: 20),
          _buildChartContainer(
            title: "Weekly Trend",
            child: _buildLineChart(),
          ),
          const SizedBox(height: 50),
          _buildChartContainer(
            title: "Average Macros",
            child: _buildPieChart(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Details (List) ───
  Widget _buildDetails() {
    final detailsList = _compiledDetailsList;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 25),
          _buildToggleSwitch(),
          const SizedBox(height: 40),
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detailsList.length,
            itemBuilder: (context, index) {
              final item = detailsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: _CustomItem(
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
    );
  }

  // ─── Shared widgets ───
  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.track_changes, size: 30, color: redColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Goal", style: TextStyle(color: Colors.grey)),
              Text(
                "${_goalCal.toStringAsFixed(0)} cal",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleItem("Overview", _isOverview)),
          Expanded(child: _toggleItem("Details", !_isOverview)),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOverview = (text == "Overview");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 25),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }

  // ─── Dynamic Bar chart ───
  Widget _buildBarChart() {
    double maxCal = _weeklyProgress.isEmpty
        ? 2600
        : _weeklyProgress
            .map<double>((d) => (d['calories'] ?? 0.0).toDouble())
            .reduce((a, b) => a > b ? a : b);

    if (maxCal < _goalCal) maxCal = _goalCal;
    maxCal = (maxCal * 1.15).clamp(1000.0, double.infinity); // dynamic padding

    return BarChart(
      BarChartData(
        maxY: maxCal,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barGroups: List.generate(_weeklyProgress.length, (index) {
          final cal = (_weeklyProgress[index]['calories'] ?? 0.0).toDouble();
          final color = cal > _goalCal ? redColor : darkBlueColor;
          return _bar(index, cal, color);
        }),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: _goalCal,
              color: Colors.green.withOpacity(0.5),
              strokeWidth: 2,
              dashArray: [6, 6],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                labelResolver: (line) => "Goal: ${_goalCal.toStringAsFixed(0)}",
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 18,
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  // ─── Dynamic Line chart ───
  Widget _buildLineChart() {
    double maxCal = _weeklyProgress.isEmpty
        ? 2600
        : _weeklyProgress
            .map<double>((d) => (d['calories'] ?? 0.0).toDouble())
            .reduce((a, b) => a > b ? a : b);

    if (maxCal < _goalCal) maxCal = _goalCal;
    maxCal = (maxCal * 1.15).clamp(1000.0, double.infinity);

    final spots = List.generate(_weeklyProgress.length, (index) {
      final cal = (_weeklyProgress[index]['calories'] ?? 0.0).toDouble();
      return FlSpot(index.toDouble(), cal);
    });

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_weeklyProgress.length - 1).toDouble().clamp(1.0, double.infinity),
        minY: 0,
        maxY: maxCal,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxCal / 4,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.05)),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.05)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxCal / 4,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 35,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index >= 0 && index < _weeklyProgress.length) {
                  final dateStr = _weeklyProgress[index]['date']?.toString() ?? '';
                  DateTime? dt;
                  try {
                    dt = DateTime.parse(dateStr);
                  } catch (_) {}
                  return SideTitleWidget(
                    meta: meta,
                    space: 10,
                    child: Text(
                      dt != null ? DateFormat('E').format(dt) : '?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
            isCurved: true,
            curveSmoothness: 0.35,
            color: Colors.blueAccent.withOpacity(0.7),
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  // ─── Dynamic Pie chart (Average Macro Percentages) ───
  Widget _buildPieChart() {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final day in _weeklyProgress) {
      totalProtein += (day['protein'] ?? 0.0);
      totalCarbs += (day['carbs'] ?? 0.0);
      totalFats += (day['fats'] ?? 0.0);
    }

    if (totalProtein == 0 && totalCarbs == 0 && totalFats == 0) {
      // Fallback ratios from user's custom macro targets (from plan/user entry)
      totalProtein = _goalProtein;
      totalCarbs = _goalCarbs;
      totalFats = _goalFats;
    }

    final double totalGrams = totalProtein + totalCarbs + totalFats;

    double proteinPct = 25;
    double carbsPct = 50;
    double fatsPct = 25;

    if (totalGrams > 0) {
      proteinPct = (totalProtein / totalGrams) * 100;
      carbsPct = (totalCarbs / totalGrams) * 100;
      fatsPct = (totalFats / totalGrams) * 100;
    }

    // Round to integers and adjust to sum to exactly 100%
    int proteinRound = proteinPct.round();
    int carbsRound = carbsPct.round();
    int fatsRound = fatsPct.round();

    int sum = proteinRound + carbsRound + fatsRound;
    if (sum > 0) {
      int diff = 100 - sum;
      if (diff != 0) {
        // Adjust the largest one to minimize relative error
        if (proteinRound >= carbsRound && proteinRound >= fatsRound) {
          proteinRound += diff;
        } else if (carbsRound >= proteinRound && carbsRound >= fatsRound) {
          carbsRound += diff;
        } else {
          fatsRound += diff;
        }
      }
    } else {
      carbsRound = 50;
      proteinRound = 25;
      fatsRound = 25;
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: 270,
        sections: [
          PieChartSectionData(
            value: carbsRound.toDouble(),
            color: redColor,
            radius: 70,
            showTitle: false,
            badgeWidget: _buildBadge("Carbs:\n$carbsRound%", redColor, 0),
            badgePositionPercentageOffset: 1.35,
          ),
          PieChartSectionData(
            value: fatsRound.toDouble(),
            color: darkBlueColor,
            radius: 70,
            showTitle: false,
            badgeWidget: _buildBadge("Fats:\n$fatsRound%", darkBlueColor, 0),
            badgePositionPercentageOffset: 1.35,
          ),
          PieChartSectionData(
            value: proteinRound.toDouble(),
            color: yellowColor,
            radius: 70,
            showTitle: false,
            badgeWidget: _buildBadge("Protein:\n$proteinRound%", yellowColor, 0),
            badgePositionPercentageOffset: 1.35,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, double extraPadding) {
    return Padding(
      padding: EdgeInsets.only(left: extraPadding),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  FlTitlesData _titles() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (double value, TitleMeta meta) => Text(
            value.toInt().toString(),
            style: const TextStyle(color: Colors.black, fontSize: 11),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 40,
          getTitlesWidget: (double value, TitleMeta meta) {
            int index = value.toInt();
            if (index >= 0 && index < _weeklyProgress.length) {
              final dateStr = _weeklyProgress[index]['date']?.toString() ?? '';
              DateTime? dt;
              try {
                dt = DateTime.parse(dateStr);
              } catch (_) {}
              return SideTitleWidget(
                meta: meta,
                space: 15,
                child: Text(
                  dt != null ? DateFormat('E').format(dt) : '?',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ─── Custom item for the Details list ───
class _CustomItem extends StatelessWidget {
  final double width;
  final String weekday;
  final String date;
  final String calories;
  final String gainorloss;
  final String percentage;
  final int color;

  const _CustomItem({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
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
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        gainorloss,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(color),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        percentage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
