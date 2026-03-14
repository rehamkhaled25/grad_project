import 'package:flutter/material.dart';

class PremiumPlanScreen extends StatelessWidget {
  const PremiumPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Your Premium',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600,fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SubscriptionStatusCard(),
            const SizedBox(height: 30),
            const Text(
              'Your Benefits',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 12),
            const BenefitsContainer(),
          ],
        ),
      ),
    );
  }
}


class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
      
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image(image: AssetImage('assets/images/tiny_avocado.png'),),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black),
                      ),
                      Text(
                        'SUBSCRIBED',
                        style: TextStyle(
                          color: Color(0xffD90C0C),
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'DUE 25/6/2026',
                  style: TextStyle(color: Color(0xffD9D9D9), fontSize: 12,fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
       
        Positioned(
          top: -10,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xffD90C0C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: const Text(
              'Subscription',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}


class BenefitsContainer extends StatelessWidget {
  const BenefitsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          BenefitItem(text: 'unlimited meal plan'),
          BenefitItem(text: 'advanced analytic'),
          BenefitItem(text: 'custom macro tracking'),
          BenefitItem(text: 'priority support'),
          BenefitItem(text: 'Ad-free experience'),
          SizedBox(height: 24),
          Text(
            'Price: 25.99',
            style: TextStyle(
              color: Color(0xffD90C0C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class BenefitItem extends StatelessWidget {
  final String text;
  const BenefitItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Image(image: AssetImage('assets/images/check.png'),),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 11),
          ),
        ],
      ),
    );
  }
}