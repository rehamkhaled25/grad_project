import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  int streakCount = 480;
  bool streakActive = false;

  List<DateTime> loggedDays = [
    DateTime(2026, 2, 1),
    DateTime(2026, 2, 2),
    DateTime(2026, 2, 3),
  ];

  bool isLogged(DateTime day) {
    return loggedDays.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
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
                          const Text(
                            "Keep Going",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// FIRE OR NO FIRE
                          Image.asset(
                            streakActive
                                ? "assets/images/fire.png"
                                : "assets/images/no_fire.png",
                            height: 90,
                          ),

                          /// CLOUD ABOVE (ONLY WHEN NOT ACTIVE)
                          if (!streakActive)
                            Positioned(
                              top: 0,
                              child: Image.asset(
                                "assets/images/cloud.png",
                                height: 80,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// MESSAGE BOX
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
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(text: "This is your "),
                            TextSpan(
                              text: "longest",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: " streak yet!\nYou've kept it for 6 weeks",
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

              /// CALENDAR
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.grey.shade200,
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     padding: const EdgeInsets.only(top: 10, bottom: 10),
              //     child: TableCalendar(
              //       firstDay: DateTime.utc(2020, 1, 1),
              //       lastDay: DateTime.utc(2030, 12, 31),
              //       focusedDay: focusedDay,

              //       selectedDayPredicate: (day) => isSameDay(selectedDay, day),

              //       onDaySelected: (selected, focused) {
              //         setState(() {
              //           selectedDay = selected;
              //           focusedDay = focused;
              //         });
              //       },

              //       headerStyle: const HeaderStyle(
              //         formatButtonVisible: false,
              //         titleCentered: true,
              //       ),

              //       calendarStyle: const CalendarStyle(
              //         todayDecoration: BoxDecoration(
              //           color: Colors.orange,
              //           shape: BoxShape.circle,
              //         ),
              //       ),

              //       calendarBuilders: CalendarBuilders(
              //         defaultBuilder: (context, day, focusedDay) {
              //           if (isLogged(day)) {
              //             return Container(
              //               margin: const EdgeInsets.all(6),
              //               decoration: const BoxDecoration(
              //                 color: Colors.red,
              //                 shape: BoxShape.circle,
              //               ),
              //               child: Center(
              //                 child: Text(
              //                   "${day.day}",
              //                   style: const TextStyle(color: Colors.white),
              //                 ),
              //               ),
              //             );
              //           }
              //           return null;
              //         },
              //       ),
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 20),

              // /// BUTTONS
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: ElevatedButton.icon(
              //           onPressed: () {
              //             print("3 days logged");
              //           },
              //           icon: const Icon(Icons.check_circle, color: Colors.red),
              //           label: const Text("3 days logged"),
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.white,
              //             foregroundColor: Colors.black,
              //             side: const BorderSide(color: Colors.grey),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 10),
              //       Expanded(
              //         child: ElevatedButton.icon(
              //           onPressed: () {
              //             print("badge pressed");
              //           },
              //           icon: const Icon(
              //             Icons.emoji_events,
              //             color: Colors.yellow,
              //           ),
              //           label: const Text("1 badge earned"),
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.white,
              //             foregroundColor: Colors.black,
              //             side: const BorderSide(color: Colors.grey),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
                        const Text(
                          "February 2026",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.chevron_left),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// CALENDAR CARD
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xffF3F3F3),
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
                              color: Color(0xffF3F3F3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.red),
                                SizedBox(width: 8),
                                Text("3 days logged"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Color(0xffF3F3F3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emoji_events, color: Colors.orange),
                                SizedBox(width: 8),
                                Text("1 badge earned"),
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
