import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Hello, Mohanad",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Remember why you started..",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const CircleAvatar(
                    radius: 22,

                    backgroundImage: AssetImage(
                      'assets/images/placeholder_profile.png',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              SizedBox(
                height: 70,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: 8,

                  itemBuilder: (context, index) {

                    final days = [
                      "Sat", "Sun", "Mon", "Tue",
                      "Wed", "Thu", "Fri", "Sat"
                    ];

                    final dates = [
                      11, 12, 13, 14, 15, 16, 17, 18
                    ];

                    bool active =
                        index == 2 || index == 3 || index == 4;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),

                      child: Column(
                        children: [

                          CircleAvatar(
                            radius: 22,

                            backgroundColor: active
                                ? const Color(0xffD90C0C)
                                : const Color(0xffDEDEDE),

                            child: Text(
                              dates[index].toString(),

                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(days[index]),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: size.width,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [

                        Text(
                          "Today's Progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "On Track",
                          style: TextStyle(
                            color: Color(0xffD90C0C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CircularPercentIndicator(
                      radius: 95,

                      lineWidth: 8,

                      percent: 1600 / 2400,

                      animation: true,

                      circularStrokeCap:
                          CircularStrokeCap.round,

                      progressColor:
                          const Color(0xffD90C0C),

                      backgroundColor:
                          Colors.grey.shade300,

                      center: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: const [

                          Text(
                            "1600",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text("of 2400"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: const [

                        ProgressItem(
                          img: 'assets/images/bultorone fireee.png',
                          label: "400\nBurned",
                        ),

                        ProgressItem(
                          img: 'assets/images/target.png',
                          label: "800\nRemaining",
                        ),

                        ProgressItem(
                          img: 'assets/images/chart.png',
                          label: "66.6%\nProgress",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Recently Logged",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 270,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: 3,

                  itemBuilder: (context, index) {
                    return const FoodCard();
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
class FoodCard extends StatelessWidget {
  const FoodCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 240,

      margin: const EdgeInsets.only(right: 15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),

            child: Image.network(
              "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",

              height: 120,

              width: double.infinity,

              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Power Breakfast Bowl",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: const [

                    Text(
                      "8:00 AM",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),

                    Text(
                      "520 cal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [

                    const _MacroCircle(
                      color: Colors.red,
                      percent: 0.7,
                    ),

                    const SizedBox(width: 3),

                    const _MacroCircle(
                      color: Colors.grey,
                      percent: 0.5,
                    ),

                    const SizedBox(width: 3),

                    const _MacroCircle(
                      color: Colors.black,
                      percent: 0.6,
                    ),

                    const SizedBox(width: 20),

                    SizedBox(
                      width: 80,
                      height: 19,

                      child: ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),

                        child: const Text(
                          "View Details",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: const [

                    MicroDot(color: Colors.red),
                    Text(" Protein 30g ",style:TextStyle(fontSize:10,fontWeight:FontWeight.bold)),

                    MicroDot(color: Colors.blue),
                    Text(" Carbs 10g ",style:TextStyle(fontSize:10,fontWeight:FontWeight.bold)),

                    MicroDot(color: Colors.orange),
                    Text(" Fats 30g ",style:TextStyle(fontSize:10,fontWeight:FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _MacroCircle extends StatelessWidget {

  final Color color;
  final double percent;

  const _MacroCircle({
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        CircularPercentIndicator(
          radius: 10,

          lineWidth: 3,

          percent: percent,

          animation: true,

          circularStrokeCap:
              CircularStrokeCap.round,

          progressColor: color,

          backgroundColor:
              color.withOpacity(0.2),
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}

class MicroDot extends StatelessWidget {

  final Color color;

  const MicroDot({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return CircleAvatar(
      radius: 5,
      backgroundColor: color,
    );
  }
}

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

        Image.asset(
          img,
          width: 28,
          height: 28,
        ),

        const SizedBox(height: 6),

        Text(
          label,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}