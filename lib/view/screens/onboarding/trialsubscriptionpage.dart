import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/app_router.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';

class TrialSubscriptionPage extends StatefulWidget {
  const TrialSubscriptionPage({super.key});

  @override
  State<TrialSubscriptionPage> createState() =>
      _TrialSubscriptionPageState();
}

class _TrialSubscriptionPageState extends State<TrialSubscriptionPage> {
  int selectedPlanIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "skip",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              decoration:
                                  TextDecoration.underline,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "How your trial 7-day free\ntrial works",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Column(
                          children: [
                            TimelineStep(
                              stepIndex: 0,
                              title: "Complete Sign-up",
                              isDone: true,
                              iconData: Icons.check,
                              isLast: false,
                            ),
                            TimelineStep(
                              stepIndex: 1,
                              title:
                                  "Today: Get instant Access",
                              isDone: false,
                              iconData: Icons.lock,
                              isLast: false,
                              isActive: true,
                            ),
                            TimelineStep(
                              stepIndex: 2,
                              title:
                                  "Day 5: Get Trial Reminder",
                              isDone: false,
                              iconData: Icons.notifications,
                              isLast: false,
                            ),
                            TimelineStep(
                              stepIndex: 3,
                              title: "Day 7: Trial Ends",
                              isDone: false,
                              iconData: Icons.favorite,
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        PlanCard(
                          title: "1 Month",
                          price: "\$8.00 / MO",
                          isPopular: false,
                          isSelected:
                              selectedPlanIndex == 0,
                          onTap: () {
                            setState(() {
                              selectedPlanIndex = 0;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        PlanCard(
                          title: "12 Month",
                          price: "\$4.99 / MO",
                          oldPrice: "\$95.88",
                          newPrice: "\$59.99",
                          isPopular: true,
                          isSelected:
                              selectedPlanIndex == 1,
                          onTap: () {
                            setState(() {
                              selectedPlanIndex = 1;
                            });
                          },
                        ),
                        const Spacer(),
                        ContinueButton(
                          onPressed: () {
                            AuthState.isLoggedIn = true;
                            context.go('/home');
                          },
                          txt: "Continue",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TimelineStep extends StatelessWidget {
  final int stepIndex;
  final String title;
  final bool isDone;
  final IconData iconData;
  final bool isLast;
  final bool isActive;

  const TimelineStep({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.isDone,
    required this.iconData,
    required this.isLast,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFutureStep = stepIndex >= 2;

    final Color iconBg =
        (isDone || isActive)
            ? Colors.black
            : const Color(0xffB9B7C0);

    final Color iconColor =
        (isDone || isActive)
            ? Colors.white
            : isFutureStep
                ? const Color(0xff403D3D)
                : Colors.white;

    final Color lineColor =
        isDone || isActive
            ? Colors.black
            : Colors.grey.shade300;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconData,
                    size: 16, color: iconColor),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding:
              const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color: Colors.black,
              decoration: isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? oldPrice;
  final String? newPrice;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    this.oldPrice,
    this.newPrice,
    required this.isPopular,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        isSelected
            ? Colors.red
            : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              constraints:
                  const BoxConstraints(
                      minHeight: 95),
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: borderColor,
                    width: 1.5),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                      if (oldPrice != null &&
                          newPrice != null)
                        Row(
                          children: [
                            Text(
                              oldPrice!,
                              style:
                                  const TextStyle(
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                                color:
                                    Colors.black,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                            const SizedBox(
                                width: 8),
                            Text(
                              newPrice!,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    Colors.black,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Text(
                    price,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: isSelected
                      ? Colors.red
                      : Colors.black,
                  borderRadius:
                      BorderRadius
                          .circular(20),
                ),
                child: const Text(
                  "Popular",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}