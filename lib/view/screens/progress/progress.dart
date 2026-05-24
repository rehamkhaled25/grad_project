import 'package:flutter/material.dart';
import 'package:graduation_project/services/food_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<double> values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  double get average => values.every((v) => v == 0) ? 0 : values.reduce((a, b) => a + b) / values.length;

  int _currentIndex = 2;

  // Dynamic data
  String _caloriesText = '...';
  String _streakText = '...';
  String _activeText = '...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        FoodService().getWeeklyProgress().catchError((_) => <Map<String, dynamic>>[]),
        FoodService().getDailyProgress().catchError((_) => <String, dynamic>{}),
        FoodService().getStreak().catchError((_) => <String, dynamic>{}),
      ]);

      final weekly = results[0] as List<Map<String, dynamic>>;
      final daily = results[1] as Map<String, dynamic>;
      final streak = results[2] as Map<String, dynamic>;

      final goalCal = ((daily['goals'] as Map?)?['calories'] ?? 2400).toDouble();
      final consumedCal = ((daily['consumed'] as Map?)?['calories'] ?? 0).toDouble();

      if (mounted) {
        setState(() {
          // Weekly chart values (as ratios of goal)
          if (weekly.isNotEmpty && goalCal > 0) {
            values = weekly.map<double>((d) {
              final cal = (d['calories'] ?? 0).toDouble();
              return (cal / goalCal).clamp(0.0, 1.0);
            }).toList();
          }

          _caloriesText = consumedCal.toStringAsFixed(0);
          _streakText = '${streak['streak_count'] ?? 0} days';
          _activeText = '${streak['total_days_logged'] ?? 0} days';
        });

        _controller.forward();
      }
    } catch (_) {
      if (mounted) _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- دالة إظهار الـ Dialog لإضافة وزن جديد ---
  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // حواف دائرية للبوب أب
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // عشان البوب أب تاخد مساحة المحتوى بس
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر (العنوان + علامة X)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Weight Log',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context), // لقفل البوب أب
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFEEEEEE), thickness: 1), // الخط الفاصل
                const SizedBox(height: 16),

                // إدخال الوزن
                const Text(
                  'Weight (kg/lbs)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your weight',
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5), // لون رمادي فاتح
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),

                // إدخال التاريخ
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '02/24/26',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // زراير Cancel و Save
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // هنا ممكن تحط الكود اللي بيحفظ الداتا بعدين
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save Log',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {},
                    ),
                  ),
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // main summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.track_changes, color: Colors.black),
                          SizedBox(width: 6),
                          Text(
                            'CURRENT WEIGHT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '170',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'lbs',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Start: ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: '180  ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextSpan(
                              text: 'Goal: ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: '160',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Progress to goal:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 10,
                          backgroundColor: Color(0xFFE0E0E0),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Label(),
                        SizedBox(height: 6),
                        Text(
                          '10 lbs lost',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // small stat cards row
            Row(
              children: [
                Expanded(
                    child: _stat(
                        Icons.eco_outlined, _caloriesText, 'Calories', Colors.red)),
                const SizedBox(width: 12),
                Expanded(
                    child: _stat(Icons.local_fire_department_outlined, _streakText,
                        'Streak', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _stat(Icons.monitor_heart_outlined, _activeText,
                        'Active', Colors.blueGrey)),
              ],
            ),

            const SizedBox(height: 16),

            // weekly calories chart
            _chart(),

            const SizedBox(height: 16),

            // weight journey graph card
            _weightJourneyCard(),

            const SizedBox(height: 16),

            // weight log timeline card
            _weightLogCard(context), // باصينا الـ context هنا عشان الـ Dialog

            const SizedBox(height: 16),

            // الكارت الخاص بالـ Milestone
            _milestoneCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _milestoneCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEAEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.red.shade600,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_open_rounded,
            size: 44,
            color: Colors.black,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Milestone Unlocked!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD90C0C), // اللون اللي طلبته للـ XP
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+75 XP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF757575),
                    ),
                    children: [
                      TextSpan(
                        text: 'You have achieved your ',
                      ),
                      TextSpan(
                        text: '7-day streak!\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Unlocked: ',
                        style: TextStyle(
                          color: Colors.black
                        )
                      ),
                      TextSpan(
                        text: 'Consistency Champion ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Avatar',
                        style:
                          TextStyle(
                            color: Colors.black
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Check it out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    const chartHeight = 160.0;

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Calories',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Details >',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final avgY = chartHeight * (1 - average) * _controller.value;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AvgLinePainter(y: avgY),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(values.length, (i) {
                        final isFriday = i == 4;
                        final h = chartHeight * values[i] * _controller.value;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 18,
                              height: h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isFriday
                                      ? [
                                    Colors.red.shade300,
                                    Colors.red.shade800,
                                  ]
                                      : [
                                    Colors.red.withOpacity(0.2),
                                    Colors.red.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[i],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightJourneyCard() {
    final data = <double>[
      175, 175, 173, 173, 170, 170, 165, 171, 169, 169.1
    ];
    final segments = ['1W', '1M', '6M', '1Y', 'ALL'];
    const selected = 4;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight Journey',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(segments.length, (i) {
                final active = i == selected;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        segments[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _InteractiveWeightChart(data: data),
          ),
        ],
      ),
    );
  }

  // ضفنا هنا BuildContext عشان نستخدمه في الـ Dialog
  Widget _weightLogCard(BuildContext context) {
    final logs = [
      {'date': 'Mar 1, 2025', 'weight': '70kg'},
      {'date': 'Feb 15, 2025', 'weight': '75kg'},
      {'date': 'Jan 31, 2025', 'weight': '76kg'},
      {'date': 'Jan 24, 2025', 'weight': '77kg'},
      {'date': 'Jan 1, 2025', 'weight': '80kg'},
    ];

    const dotSize = 12.0;
    const lineX = 22.0;
    const rowHeight = 52.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // --- تعديل زرار Add ---
              InkWell(
                onTap: () => _showAddWeightDialog(context), // استدعاء دالة الـ Popup
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: logs.length * rowHeight,
            child: Stack(
              children: [
                Positioned(
                  left: lineX + dotSize / 2 - 1,
                  top: rowHeight / 2,
                  bottom: rowHeight / 2,
                  child: Container(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                Column(
                  children: List.generate(logs.length, (i) {
                    return SizedBox(
                      height: rowHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: lineX),
                          Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              logs[i]['date']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 52,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Text(
                                  logs[i]['weight']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: _box(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '10 lbs to go',
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _AvgLinePainter extends CustomPainter {
  final double y;

  _AvgLinePainter({required this.y});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.85)
      ..strokeWidth = 2;

    const dash = 6.0;
    const space = 5.0;

    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dash, y),
        paint,
      );
      x += dash + space;
    }
  }

  @override
  bool shouldRepaint(covariant _AvgLinePainter oldDelegate) {
    return oldDelegate.y != y;
  }
}

class _InteractiveWeightChart extends StatefulWidget {
  final List<double> data;

  const _InteractiveWeightChart({required this.data});

  @override
  State<_InteractiveWeightChart> createState() =>
      _InteractiveWeightChartState();
}

class _InteractiveWeightChartState extends State<_InteractiveWeightChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) => setState(() => selectedIndex = null),
      child: CustomPaint(
        painter: _WeightLinePainter(
          data: widget.data,
          selectedIndex: selectedIndex,
        ),
        child: Container(),
      ),
    );
  }

  void _update(Offset pos) {
    final index = (pos.dx / context.size!.width * (widget.data.length - 1))
        .round()
        .clamp(0, widget.data.length - 1);

    setState(() {
      selectedIndex = index;
    });
  }
}

class _WeightLinePainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;

  _WeightLinePainter({
    required this.data,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    const minWeight = 160.0;
    const maxWeight = 180.0;

    double norm(double v) => (v - minWeight) / (maxWeight - minWeight);

    const horizontalPadding = 28.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - bottomPadding;

    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = (chartHeight / gridLines) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    canvas.drawLine(
      Offset(horizontalPadding, chartHeight),
      Offset(size.width - horizontalPadding, chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(horizontalPadding, 0),
      Offset(horizontalPadding, chartHeight),
      axisPaint,
    );

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = horizontalPadding + (i / (data.length - 1)) * chartWidth;
      final y = chartHeight - (norm(data[i]) * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );

      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.withOpacity(0.25),
          Colors.red.withOpacity(0.10),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, chartHeight),
      );

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(path, linePaint);

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final p = points[selectedIndex!];
      final value = data[selectedIndex!];

      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, chartHeight),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );

      canvas.drawCircle(
        p,
        5,
        Paint()..color = Colors.black,
      );

      canvas.drawCircle(
        p,
        10,
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(1)} lbs',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        p.dx - textPainter.width / 2,
        p.dy - 30,
      );

      final bg = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - 6,
          offset.dy - 4,
          textPainter.width + 12,
          textPainter.height + 8,
        ),
        const Radius.circular(8),
      );

      canvas.drawRRect(
        bg,
        Paint()..color = Colors.white,
      );

      canvas.drawRRect(
        bg,
        Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      textPainter.paint(canvas, offset);
    }

    final months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];

    const textStyle = TextStyle(
      fontSize: 11,
      color: Colors.black87,
    );

    for (int i = 0; i < months.length; i++) {
      final x = horizontalPadding + (i / (months.length - 1)) * chartWidth;

      final tp = TextPainter(
        text: TextSpan(text: months[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}