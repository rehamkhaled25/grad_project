import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';

class PaymentApplication extends StatefulWidget {
  final Map<String, dynamic>? planData;
  const PaymentApplication({super.key, this.planData});

  @override
  State<PaymentApplication> createState() => _PaymentApplicationState();
}

class _PaymentApplicationState extends State<PaymentApplication> {
  int selectedMethod = 0; // 0: Card, 1: PayPal, 2: Google Pay, 3: Apple Pay
  bool _isProcessing = false;



  Widget _buildPaymentOption(int index, String img) {
    final isSelected = selectedMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMethod = index;
          });
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xffD90C0C) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(img, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardPreview({
    required String cardNumber,
    required String expiry,
    required String cardHolder,
    required String brandLogo,
    required String cardType,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardType,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
              Image.asset(
                brandLogo,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CARD HOLDER",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cardHolder.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    final planName = widget.planData?['name'] ?? 'Premium Plan';
    final price = widget.planData?['price'] ?? 9.99;

    // Determine card preview based on selected method
    Widget cardPreview;
    String brandLogo = "assets/images/Card.png";
    String cardType = "Credit Card";
    List<Color> gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)];

    if (selectedMethod == 0) {
      cardType = "Mastercard";
      brandLogo = "assets/images/mastercard-full-svgrepo-com 1.png";
      gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)];
    } else if (selectedMethod == 1) {
      cardType = "PayPal Card";
      brandLogo = "assets/images/paypal-svgrepo-com 1.png";
      gradientColors = [const Color(0xFF003087), const Color(0xFF0079C1)];
    } else if (selectedMethod == 2) {
      cardType = "Google Pay Card";
      brandLogo = "assets/images/google-pay-svgrepo-com 2.png";
      gradientColors = [const Color(0xFF4285F4), const Color(0xFF34A853)];
    } else {
      cardType = "Apple Pay Card";
      brandLogo = "assets/images/apple-pay-svgrepo-com 1.png";
      gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF444444)];
    }

    cardPreview = _buildCreditCardPreview(
      cardNumber: "•••• •••• •••• ••••",
      expiry: "MM/YY",
      cardHolder: "CARD HOLDER",
      brandLogo: brandLogo,
      cardType: cardType,
      gradientColors: gradientColors,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
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

                    SizedBox(height: screenHeight * 0.02),

                    // Selector Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPaymentOption(0, "assets/images/mastercard-full-svgrepo-com 1.png"),
                        const SizedBox(width: 10),
                        _buildPaymentOption(1, "assets/images/paypal-svgrepo-com 1.png"),
                        const SizedBox(width: 10),
                        _buildPaymentOption(2, "assets/images/google-pay-svgrepo-com 2.png"),
                        const SizedBox(width: 10),
                        _buildPaymentOption(3, "assets/images/apple-pay-svgrepo-com 1.png"),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Dynamic Card Preview
                    Center(
                      child: cardPreview,
                    ),

                    SizedBox(height: screenHeight * 0.05),

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
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    ContinueButton(
                      onPressed: () {
                        context.push("/creditCardInfo", extra: {
                          'planData': widget.planData,
                          'selectedMethod': selectedMethod,
                        });
                      },
                      txt: "Confirm Order",
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}