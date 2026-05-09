// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class WeeklyBreakdownScreen extends StatelessWidget {
//   const WeeklyBreakdownScreen({super.key});

//   static const Color darkBlueColor = Color(0xFF01436E);
//   static const Color redColor = Color(0xFFD22F27);
//   static const Color yellowColor = Color(0xFFFDC700);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFBFB),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const Icon(Icons.arrow_back, color: Colors.black),
//         toolbarHeight: 80,
//         titleSpacing: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Weekly Breakdown',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: const BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 const Text(
//                   "Jan 20-Jan 26, 2026",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             _buildGoalCard(),
//             const SizedBox(height: 25),
//             _buildToggleSwitch(),
//             const SizedBox(height: 25),
//             _buildChartContainer(
//               title: "Daily Calorie Intake",
//               child: _buildBarChart(),
//             ),
//             const SizedBox(height: 20),
//             _buildChartContainer(
//               title: "Weekly Trend",
//               child: _buildLineChart(),
//             ),
//             const SizedBox(height: 20),
//             _buildChartContainer(
//               title: "Average Macros",
//               child: _buildPieChart(),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoalCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.track_changes, size: 30),
//           SizedBox(width: 15),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Daily Goal", style: TextStyle(color: Colors.grey)),
//               Text(
//                 "2,000 cal",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleSwitch() {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F0F0),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Expanded(child: _toggleItem("Overview", true)),
//           Expanded(child: _toggleItem("Details", false)),
//         ],
//       ),
//     );
//   }

//   Widget _toggleItem(String text, bool selected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         color: selected ? Colors.white : Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Center(
//         child: Text(
//           text,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: selected ? Colors.black : Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChartContainer({required String title, required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: TextStyle(color: Colors.grey[400])),
//           const SizedBox(height: 25),
//           SizedBox(height: 220, child: child),
//         ],
//       ),
//     );
//   }

//   Widget _buildBarChart() {
//     return BarChart(
//       BarChartData(
//         maxY: 2600,
//         gridData: const FlGridData(show: false),
//         borderData: FlBorderData(show: false),
//         titlesData: _titles(),
//         barGroups: [
//           _bar(0, 2200, redColor),
//           _bar(1, 600, darkBlueColor),
//           _bar(2, 1200, redColor),
//           _bar(3, 800, darkBlueColor),
//           _bar(4, 2100, redColor),
//           _bar(5, 650, darkBlueColor),
//           _bar(6, 1500, darkBlueColor),
//         ],
//         extraLinesData: ExtraLinesData(
//           horizontalLines: [
//             HorizontalLine(
//               y: 1300,
//               color: Colors.grey.withOpacity(0.3),
//               strokeWidth: 1,
//               dashArray: [5, 5],
//             ),
//             HorizontalLine(
//               y: 1450,
//               color: Colors.lightBlueAccent.withOpacity(0.4),
//               strokeWidth: 1,
//               dashArray: [5, 5],
//             ),
//             HorizontalLine(
//               y: 2600,
//               color: Colors.grey.withOpacity(0.5),
//               strokeWidth: 1.5,
//               dashArray: [5, 5],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   BarChartGroupData _bar(int x, double y, Color color) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: y,
//           width: 18,
//           color: color,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//         ),
//       ],
//     );
//   }

//   Widget _buildLineChart() {
//     return LineChart(
//       LineChartData(
//         minX: 0,
//         maxX: 6,
//         minY: 0,
//         maxY: 1950,
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: true,
//           horizontalInterval: 650,
//           verticalInterval: 1,
//           getDrawingHorizontalLine: (value) =>
//               FlLine(color: Colors.grey.withOpacity(0.05)),
//           getDrawingVerticalLine: (value) =>
//               FlLine(color: Colors.grey.withOpacity(0.05)),
//         ),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: Colors.grey.withOpacity(0.1)),
//         ),
//         titlesData: FlTitlesData(
//           topTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           rightTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 650,
//               reservedSize: 40,
//               getTitlesWidget: (double value, TitleMeta meta) {
//                 if (value > 1950) return const SizedBox();
//                 return SideTitleWidget(
//                   axisSide: meta.axisSide,
//                   child: Text(
//                     value.toInt().toString(),
//                     style: const TextStyle(color: Colors.black, fontSize: 11),
//                   ),
//                 );
//               },
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 1,
//               reservedSize: 35,
//               getTitlesWidget: (double value, TitleMeta meta) {
//                 const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//                 int index = value.toInt();
//                 if (index >= 0 && index < days.length) {
//                   return SideTitleWidget(
//                     space: 10,
//                     axisSide: meta.axisSide,
//                     child: Text(
//                       days[index],
//                       style: TextStyle(color: Colors.grey[600], fontSize: 11),
//                     ),
//                   );
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: const [
//               FlSpot(0, 1300),
//               FlSpot(1, 1150),
//               FlSpot(2, 1250),
//               FlSpot(3, 1500),
//               FlSpot(4, 1850),
//               FlSpot(5, 1450),
//               FlSpot(6, 1600),
//             ],
//             isCurved: true,
//             curveSmoothness: 0.35,
//             color: Colors.blueAccent.withOpacity(0.7),
//             barWidth: 3,
//             dotData: const FlDotData(show: true),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPieChart() {
//     return PieChart(
//       PieChartData(
//         sectionsSpace: 0,
//         centerSpaceRadius: 0,
//         startDegreeOffset: 270,
//         sections: [
//           PieChartSectionData(
//             value: 55,
//             color: redColor,
//             radius: 100,
//             showTitle: false,
//             badgeWidget: _buildBadge("Carbs:\n47%", redColor, 40),
//             badgePositionPercentageOffset: 1.45,
//           ),
//           PieChartSectionData(
//             value: 20,
//             color: darkBlueColor,
//             radius: 100,
//             showTitle: false,
//             badgeWidget: _buildBadge("Fats:25%", darkBlueColor, 0),
//             badgePositionPercentageOffset: 1.55,
//           ),
//           PieChartSectionData(
//             value: 25,
//             color: yellowColor,
//             radius: 100,
//             showTitle: false,
//             badgeWidget: _buildBadge("Protein:\n33%", yellowColor, 0),
//             badgePositionPercentageOffset: 1.55,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBadge(String text, Color color, double extraPadding) {
//     return Padding(
//       padding: EdgeInsets.only(left: extraPadding),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   FlTitlesData _titles() {
//     return FlTitlesData(
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           interval: 650,
//           reservedSize: 40,
//           getTitlesWidget: (double value, TitleMeta meta) => Text(
//             value.toInt().toString(),
//             style: const TextStyle(color: Colors.black, fontSize: 11),
//           ),
//         ),
//       ),
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           interval: 1,
//           reservedSize: 40,
//           getTitlesWidget: (double value, TitleMeta meta) {
//             const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
//             if (value.toInt() >= 0 && value.toInt() < days.length) {
//               return SideTitleWidget(
//                 space: 15,
//                 axisSide: meta.axisSide,
//                 child: Text(
//                   days[value.toInt()],
//                   style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyBreakdownScreen extends StatefulWidget {
  const WeeklyBreakdownScreen({super.key});

  @override
  State<WeeklyBreakdownScreen> createState() => _WeeklyBreakdownScreenState();
}

class _WeeklyBreakdownScreenState extends State<WeeklyBreakdownScreen> {
  bool _isOverview = true; // true = Overview (charts), false = Details (list)

  // ─── Colors (from original WeeklyBreakdownScreen) ───
  static const Color darkBlueColor = Color(0xFF01436E);
  static const Color redColor = Color(0xFFD22F27);
  static const Color yellowColor = Color(0xFFFDC700);

  // ─── Data for the Details list ───
  final List<Map<String, dynamic>> weeklyData = [
    {
      "day": "Sun",
      "date": "Jan 20",
      "cal": "1850 cal",
      "diff": "-150 cal",
      "proc": "93%",
      "w": 180.0,
      "c": 0xff43A047,
    },
    {
      "day": "Mon",
      "date": "Jan 21",
      "cal": "2100 cal",
      "diff": "+100 cal",
      "proc": "105%",
      "w": 210.0,
      "c": 0xffD90C0C,
    },
    {
      "day": "Tue",
      "date": "Jan 22",
      "cal": "1850 cal",
      "diff": "-150 cal",
      "proc": "93%",
      "w": 150.0,
      "c": 0xff43A047,
    },
    {
      "day": "Wed",
      "date": "Jan 23",
      "cal": "1850 cal",
      "diff": "-150 cal",
      "proc": "93%",
      "w": 150.0,
      "c": 0xff43A047,
    },
    {
      "day": "Thu",
      "date": "Jan 24",
      "cal": "1850 cal",
      "diff": "-150 cal",
      "proc": "93%",
      "w": 150.0,
      "c": 0xff43A047,
    },
    {
      "day": "Fri",
      "date": "Jan 25",
      "cal": "2200 cal",
      "diff": "+200 cal",
      "proc": "110%",
      "w": 230.0,
      "c": 0xffD90C0C,
    },
    {
      "day": "Sat",
      "date": "Jan 26",
      "cal": "1850 cal",
      "diff": "-150 cal",
      "proc": "93%",
      "w": 150.0,
      "c": 0xffD90C0C,
    },
  ];

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
                const Text(
                  "Jan 20-Jan 26, 2026",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isOverview ? _buildOverview() : _buildDetails(),
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
          _buildChartContainer(title: "Weekly Trend", child: _buildLineChart()),
          const SizedBox(height: 20),
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
            itemCount: weeklyData.length,
            itemBuilder: (context, index) {
              final item = weeklyData[index];
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
      ),
      child: const Row(
        children: [
          Icon(Icons.track_changes, size: 30),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daily Goal", style: TextStyle(color: Colors.grey)),
              Text(
                "2,000 cal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 25),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }

  // ─── Bar chart ───
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        maxY: 2600,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barGroups: [
          _bar(0, 2200, redColor),
          _bar(1, 600, darkBlueColor),
          _bar(2, 1200, redColor),
          _bar(3, 800, darkBlueColor),
          _bar(4, 2100, redColor),
          _bar(5, 650, darkBlueColor),
          _bar(6, 1500, darkBlueColor),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 1300,
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 1450,
              color: Colors.lightBlueAccent.withOpacity(0.4),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 2600,
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1.5,
              dashArray: [5, 5],
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

  // ─── Line chart ───
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 1950,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 650,
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
              interval: 650,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value > 1950) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
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
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                int index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return SideTitleWidget(
                    space: 10,
                    axisSide: meta.axisSide,
                    child: Text(
                      days[index],
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
            spots: const [
              FlSpot(0, 1300),
              FlSpot(1, 1150),
              FlSpot(2, 1250),
              FlSpot(3, 1500),
              FlSpot(4, 1850),
              FlSpot(5, 1450),
              FlSpot(6, 1600),
            ],
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

  // ─── Pie chart ───
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: 270,
        sections: [
          PieChartSectionData(
            value: 55,
            color: redColor,
            radius: 100,
            showTitle: false,
            badgeWidget: _buildBadge("Carbs:\n47%", redColor, 40),
            badgePositionPercentageOffset: 1.45,
          ),
          PieChartSectionData(
            value: 20,
            color: darkBlueColor,
            radius: 100,
            showTitle: false,
            badgeWidget: _buildBadge("Fats:25%", darkBlueColor, 0),
            badgePositionPercentageOffset: 1.55,
          ),
          PieChartSectionData(
            value: 25,
            color: yellowColor,
            radius: 100,
            showTitle: false,
            badgeWidget: _buildBadge("Protein:\n33%", yellowColor, 0),
            badgePositionPercentageOffset: 1.55,
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
          interval: 650,
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
            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return SideTitleWidget(
                space: 15,
                axisSide: meta.axisSide,
                child: Text(
                  days[value.toInt()],
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
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
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
            const Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
