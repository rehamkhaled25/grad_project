import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';
import 'package:graduation_project/view/custom _widget/payment_options.dart';

class PaymentApplication extends StatelessWidget {
  final Map<String, dynamic>? planData;
  const PaymentApplication({super.key, this.planData});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final planName = planData?['name'] ?? 'Premium Plan';
    final price = planData?['price'] ?? 50.98;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
             Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.06),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      "Payment method",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Show selected plan info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Color(0xffD90C0C), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        planName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "\$${price is num ? price.toStringAsFixed(2) : price}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffD90C0C)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Add Payment Method",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(child: custom_image_holder(img: "assets/images/mastercard-full-svgrepo-com 1.png")),
                  SizedBox(width: 10),
                  Expanded(child: custom_image_holder(img: 'assets/images/paypal-svgrepo-com 1.png')),
                  SizedBox(width: 10),
                  Expanded(child: custom_image_holder(img: 'assets/images/google-pay-svgrepo-com 2.png')),
                  SizedBox(width: 10),
                  Expanded(child: custom_image_holder(img: 'assets/images/apple-pay-svgrepo-com 1.png')),
                ],
              ),

              SizedBox(height: screenHeight * 0.09),

             
              Center(
                child: Image(
                  image: const AssetImage('assets/images/credit card.png'),
                  width: screenWidth * 0.85, 
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: screenHeight * 0.08),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Payment",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "\$${price is num ? price.toStringAsFixed(2) : price}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          " USD",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8E8E93),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.08),

             
              ContinueButton(
                onPressed: () {
                  context.push("/creditCardInfo", extra: planData);
                },
                txt: "Confirm Order",
              ),
            ],
          ),
        ),
      ),
    );
  }
}