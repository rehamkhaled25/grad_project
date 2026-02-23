import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/custom_navbar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // This now pushes the notification to the far right
                children: [
                  // Left Side: Avatar + Text
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('assets/images/placeholder_profile.png'),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Hello, Mohanad",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Remember why you started..",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff464646)),
                              ),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          // navigation to the notification page goes here
                        },
                     
                        icon: const Icon(Icons.notifications, size: 20, color: Color(0xff210701)),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Image.asset('assets/images/streak.png', height: 18),
                            const Text(
                              " 48",
                              style: TextStyle(
                                  color: Color(0xffD9D9D9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(8, (index) {
                    final days = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                    final dates = [11, 12, 13, 14, 15, 16, 17, 18];
                    List<Color> bgColors = [
                      const Color(0xFF4CAF50), const Color(0xFFD90C0C), const Color(0xFFFFC107),
                      const Color(0xFFD90C0C), const Color(0xFF4CAF50), const Color(0xFFFFC107),
                      const Color(0xFFD90C0C), const Color(0xFF4CAF50)
                    ];

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: bgColors[index],
                          child: Text(
                            dates[index].toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(days[index],
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff141414),
                                fontWeight: FontWeight.bold)),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 15),

               SizedBox(
                height: 360,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildProgressCard(size),
                    Container(
                      margin: const EdgeInsets.all(10),
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Page Indicator Dots
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
                      color: _currentPage == index ? Colors.black : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              const Text("Recently Logged", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

             
              SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) => const FoodCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(Size size) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Today's Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("On Track", style: TextStyle(color: Color(0xffD90C0C), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 15),
              CircularPercentIndicator(
                radius: constraints.maxHeight * 0.25,
                lineWidth: 7,
                percent: 0.66,
                progressColor: const Color(0xffD90C0C),
                backgroundColor: Colors.grey.shade100,
                circularStrokeCap: CircularStrokeCap.round,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FittedBox(child: Text("1600", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold))),
                    Text("of 2400", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  ProgressItem(img: 'assets/images/bultorone fireee.png', label: "400\nBurned"),
                  ProgressItem(img: 'assets/images/target.png', label: "800\nRemaining"),
                  ProgressItem(img: 'assets/images/chart.png', label: "66.6%\nProgress"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20, bottom: 15, left: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.asset('assets/images/food log.png', height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                        child: Text("Power Breakfast Bowl",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            overflow: TextOverflow.ellipsis)),
                    Column(
                      children: const [
                        Text("520", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("   Calories", style: TextStyle(fontSize: 8, color: Colors.black,fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const Text("  8:00am", style: TextStyle(color: Colors.black, fontSize: 8,fontWeight: FontWeight.bold)),
                const SizedBox(height: 20,),
                  Row(
                  children: [
                    _macroCircle(0.7, Colors.red),
                    const SizedBox(width: 8),
                    _macroCircle(0.4, Colors.black),
                    const SizedBox(width: 8),
                    _macroCircle(0.6, Colors.grey),
                    const Spacer(),
                    
                    GestureDetector(
                        onTap:(){},
                        child: Container(
                          width: 84,
                          height: 23,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: const Center(
                            child: Text("View Details",
                            
                                style: TextStyle(color: Colors.white, fontSize: 11,
                               fontWeight: FontWeight.bold
                                )),
                          ),
                        ),
                      )
                   
                  ],
                ),
                const SizedBox(height: 30),
               
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      _macroLabel(Colors.red, "Protein 30g"),
                      const SizedBox(width: 15), 
                      _macroLabel(Colors.black, "Carbs 10g"),
                      const SizedBox(width: 15), 
                      _macroLabel(Colors.grey, "Fats 30g"),
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
      radius: 18,
      lineWidth: 6,
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
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,color: Colors.black)),
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
        Image.asset(img, height: 24), // Restored Image asset
        const SizedBox(height: 6),
        FittedBox(
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
      ],
    );
  }
}