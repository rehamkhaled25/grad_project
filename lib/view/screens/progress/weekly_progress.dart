import 'package:flutter/material.dart';

class WeeklyProgress extends StatefulWidget {
  const WeeklyProgress({super.key});

  @override
  State<WeeklyProgress> createState() => _WeeklyProgressState();
}

class _WeeklyProgressState extends State<WeeklyProgress> {
  int selectedIndex = 0;

  // Data list to keep the build method clean
  final List<Map<String, dynamic>> weeklyData = [
    {"day": "Sun", "date": "Jan 20", "cal": "1850 cal", "diff": "-150 cal", "proc": "93%", "w": 180.0, "c": 0xff43A047},
    {"day": "Mon", "date": "Jan 21", "cal": "2100 cal", "diff": "+100 cal", "proc": "105%", "w": 210.0, "c": 0xffD90C0C},
    {"day": "Tue", "date": "Jan 22", "cal": "1850 cal", "diff": "-150 cal", "proc": "93%", "w": 150.0, "c": 0xff43A047},
    {"day": "Wed", "date": "Jan 23", "cal": "1850 cal", "diff": "-150 cal", "proc": "93%", "w": 150.0, "c": 0xff43A047},
    {"day": "Thu", "date": "Jan 24", "cal": "1850 cal", "diff": "-150 cal", "proc": "93%", "w": 150.0, "c": 0xff43A047},
    {"day": "Fri", "date": "Jan 25", "cal": "2200 cal", "diff": "+200 cal", "proc": "110%", "w": 230.0, "c": 0xffD90C0C},
    {"day": "Sat", "date": "Jan 26", "cal": "1850 cal", "diff": "-150 cal", "proc": "93%", "w": 150.0, "c": 0xffD90C0C},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // --- FIXED HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 24, color: Color(0xff151316)),
                  ),
                  const Text(
                    "Weekly Breakdown",
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 48),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3.335, backgroundColor: Color(0xff43A047)),
                    Text(
                      "  Jan 20-Jan 26, 2026",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff9291A5)),
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
                  
                  Image.asset('assets/images/7alazona yama el 7alazona.png',color: Colors.black,),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Daily Goal", style: TextStyle(color: Color(0xff706B6B), fontSize: 10, fontWeight: FontWeight.bold)),
                        Text("2,000 cal", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
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
                          : const Center(child: Text("Overview", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedIndex = 1),
                        child: selectedIndex == 1 
                          ? const CustomContainer(text: "Details") 
                          : const Center(child: Text("Details", style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), 

      
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20), 
                  itemCount: weeklyData.length,
                  
                  separatorBuilder: (context, index) => const SizedBox(height: 40), 
                  itemBuilder: (context, index) {
                    final item = weeklyData[index];
                    return CustomItem(
                      weekday: item['day'],
                      date: item['date'],
                      calories: item['cal'],
                      gainorloss: item['diff'],
                      percentage: item['proc'],
                      width: item['w'],
                      color: item['c'],
                    );
                  },
                ),
              ),
            ],
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
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
                Text(weekday, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
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
                      Text(calories, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
                      Text(gainorloss, style: TextStyle(color: Color(color), fontWeight: FontWeight.bold)),
                      Text(percentage, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
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