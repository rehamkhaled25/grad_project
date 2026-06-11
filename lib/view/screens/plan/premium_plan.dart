import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool _isSubscribed = false;
  String _planName = 'Premium';
  String _dueDate = '';
  bool _isLoading = true;

  // Hardcoded plan list matching backend Plan model
  static const List<Map<String, dynamic>> availablePlans = [
    {
      'id': 1,
      'name': 'Monthly Premium',
      'price': 9.99,
      'period': 'month',
      'benefits': [
        'Unlimited meal plans',
        'Advanced analytics',
        'Custom macro tracking',
        'Priority support',
        'Ad-free experience',
      ],
    },
    {
      'id': 2,
      'name': 'Yearly Premium',
      'price': 25.99,
      'period': 'year',
      'benefits': [
        'Unlimited meal plans',
        'Advanced analytics',
        'Custom macro tracking',
        'Priority support',
        'Ad-free experience',
        '2 months free',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    if (mounted) {
      setState(() {
        _isSubscribed = prefs.getBool('${prefix}premium_active') ?? false;
        _planName = prefs.getString('${prefix}premium_plan_name') ?? 'Premium';
        _dueDate = prefs.getString('${prefix}premium_due_date') ?? '';
        _isLoading = false;
      });
    }
  }

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubscriptionStatusCard(
                    isSubscribed: _isSubscribed,
                    planName: _planName,
                    dueDate: _dueDate,
                  ),
                  const SizedBox(height: 30),
                  if (_isSubscribed) ...[
                    const Text(
                      'Your Benefits',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    const _BenefitsContainer(),
                  ] else ...[
                    const Text(
                      'Choose a Plan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    ...availablePlans.map((plan) => _PlanCard(
                          plan: plan,
                          onSelect: () {
                            context.push('/paymentApplication', extra: plan);
                          },
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  final bool isSubscribed;
  final String planName;
  final String dueDate;

  const _SubscriptionStatusCard({
    required this.isSubscribed,
    required this.planName,
    required this.dueDate,
  });

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
                  const Image(image: AssetImage('assets/images/tiny_avocado.png')),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        planName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isSubscribed ? 'SUBSCRIBED' : 'NOT SUBSCRIBED',
                        style: TextStyle(
                          color: isSubscribed ? const Color(0xffD90C0C) : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 40),
              if (dueDate.isNotEmpty)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'DUE $dueDate',
                    style: const TextStyle(color: Color(0xffD9D9D9), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
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
            child: Text(
              isSubscribed ? 'Subscription' : 'Free Plan',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitsContainer extends StatelessWidget {
  const _BenefitsContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BenefitItem(text: 'Unlimited meal plans'),
          _BenefitItem(text: 'Advanced analytics'),
          _BenefitItem(text: 'Custom macro tracking'),
          _BenefitItem(text: 'Priority support'),
          _BenefitItem(text: 'Ad-free experience'),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;
  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Image(image: AssetImage('assets/images/check.png')),
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

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onSelect;

  const _PlanCard({required this.plan, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final benefits = plan['benefits'] as List? ?? [];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['name'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(b.toString(), style: const TextStyle(fontSize: 11, color: Colors.black)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${plan['price']}/${plan['period']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffD90C0C),
                ),
              ),
              ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text("Subscribe", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}