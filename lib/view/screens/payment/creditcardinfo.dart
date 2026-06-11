import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/custom _widget/continue_button.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Creditcardinfo extends StatefulWidget {
  final Map<String, dynamic>? planData;
  const Creditcardinfo({super.key, this.planData});

  @override
  State<Creditcardinfo> createState() => _CreditcardinfoState();
}

class _CreditcardinfoState extends State<Creditcardinfo> {
  int selectedMethod = 0; // 0: Card, 1: PayPal, 2: Google Pay, 3: Apple Pay
  bool isSaved = false;
  bool _isProcessing = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.planData != null && widget.planData!.containsKey('selectedMethod')) {
      selectedMethod = widget.planData!['selectedMethod'] as int;
    }
    // Re-build when text changes to dynamically update the credit card preview widget
    _nameController.addListener(_onTextChanged);
    _cardNumberController.addListener(_onTextChanged);
    _expiryController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _cardNumberController.removeListener(_onTextChanged);
    _expiryController.removeListener(_onTextChanged);
    _nameController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  String _getCardBrandLogo(int method, String cardNumber) {
    switch (method) {
      case 0:
        return 'assets/images/mastercard-full-svgrepo-com 1 (1).png';
      case 1:
        return 'assets/images/paypal-svgrepo-com 1.png';
      case 2:
        return 'assets/images/google-pay-svgrepo-com 2.png';
      case 3:
        return 'assets/images/apple-pay-svgrepo-com 1.png';
      default:
        return 'assets/images/Card.png';
    }
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final planId = widget.planData?['id'] ?? 1;
      final planName = widget.planData?['name'] ?? 'Premium';

      // Call backend plan/apply endpoint
      try {
        await FoodService().applyPlan(planId);
      } catch (e) {
        debugPrint("Plan apply backend warning: $e");
      }

      // Save premium status locally
      final prefs = await SharedPreferences.getInstance();
      final email = await ApiService().getCurrentUserEmail() ?? '';
      final prefix = email.isNotEmpty ? '${email}_' : '';
      await prefs.setBool('${prefix}premium_active', true);
      await prefs.setString('${prefix}premium_plan_name', planName);

      // Set due date
      final period = widget.planData?['period'] ?? 'month';
      final now = DateTime.now();
      final dueDate = period == 'year'
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year, now.month + 1, now.day);
      await prefs.setString('${prefix}premium_due_date', DateFormat('d/M/yyyy').format(dueDate));

      // Simulate a quick authorization delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      final methodNames = ["Credit Card", "PayPal", "Google Pay", "Apple Pay"];

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xffD90C0C), size: 64),
              const SizedBox(height: 16),
              const Text(
                "Payment Successful!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Authorized via ${methodNames[selectedMethod]}.\nYou're now subscribed to $planName",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go("/home");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Go to Home", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Payment failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

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
                    "STATUS / EXP",
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

    // Determine card preview details based on selected method and input text
    Widget cardPreview;
    String brandLogo = _getCardBrandLogo(selectedMethod, _cardNumberController.text);
    String cardType = "Credit Card";
    List<Color> gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)];

    if (selectedMethod == 0) {
      cardType = "Mastercard";
      gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF3A3A3A)];
    } else if (selectedMethod == 1) {
      cardType = "PayPal Card";
      gradientColors = [const Color(0xFF003087), const Color(0xFF0079C1)];
    } else if (selectedMethod == 2) {
      cardType = "Google Pay Card";
      gradientColors = [const Color(0xFF4285F4), const Color(0xFF34A853)];
    } else {
      cardType = "Apple Pay Card";
      gradientColors = [const Color(0xFF1E1E1E), const Color(0xFF444444)];
    }

    cardPreview = _buildCreditCardPreview(
      cardNumber: _cardNumberController.text.isEmpty ? "•••• •••• •••• ••••" : _cardNumberController.text,
      expiry: _expiryController.text.isEmpty ? "MM/YY" : _expiryController.text,
      cardHolder: _nameController.text.isEmpty ? "CARD HOLDER" : _nameController.text,
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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 24,
                              ),
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
                      SizedBox(height: screenHeight * 0.01),

                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(
                          color: Color(0xff8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildPaymentOption(0, "assets/images/mastercard-full-svgrepo-com 1.png"),
                          const SizedBox(width: 12),
                          _buildPaymentOption(1, "assets/images/paypal-svgrepo-com 1.png"),
                          const SizedBox(width: 12),
                          _buildPaymentOption(2, "assets/images/google-pay-svgrepo-com 2.png"),
                          const SizedBox(width: 12),
                          _buildPaymentOption(3, "assets/images/apple-pay-svgrepo-com 1.png"),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Card Live Preview widget
                      Center(child: cardPreview),

                      SizedBox(height: screenHeight * 0.04),

                      // Always display the form fields for all methods
                      const Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff8E8E93),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        label: "What's your name?",
                        controller: _nameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      const Text(
                        "Card Number",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff8E8E93),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        label: "Enter your card number",
                        hasImage: true,
                        image: _getCardBrandLogo(selectedMethod, _cardNumberController.text),
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardNumberInputFormatter(),
                        ],
                        validator: (val) {
                          final clean = val?.replaceAll(' ', '') ?? '';
                          if (clean.length != 16 || int.tryParse(clean) == null) {
                            return "Must be 16 digits";
                          }
                          if (selectedMethod == 0 && !clean.startsWith('5')) {
                            return "Mastercard must start with 5";
                          }
                          if (selectedMethod == 1 && !clean.startsWith('6')) {
                            return "PayPal Card must start with 6";
                          }
                          if (selectedMethod == 2 && !clean.startsWith('3')) {
                            return "Google Pay Card must start with 3";
                          }
                          if (selectedMethod == 3 && !clean.startsWith('4')) {
                            return "Apple Pay Card must start with 4";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "CVV",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff8E8E93),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CustomTextField(
                                  label: "123",
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  validator: (val) {
                                    final clean = val?.trim() ?? '';
                                    if (clean.length < 3 || clean.length > 4 || int.tryParse(clean) == null) {
                                      return "Must be 3-4 digits";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Expires",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff8E8E93),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CustomTextField(
                                  label: "MM/YY",
                                  controller: _expiryController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    CardExpiryInputFormatter(),
                                  ],
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return "Required";
                                    }
                                    final clean = val.trim();
                                    final regExp = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
                                    if (!regExp.hasMatch(clean)) {
                                      return "Use MM/YY";
                                    }
                                    final parts = clean.split('/');
                                    final month = int.parse(parts[0]);
                                    final year = 2000 + int.parse(parts[1]);
                                    final now = DateTime.now();
                                    final currentYear = now.year;
                                    final currentMonth = now.month;
                                    if (year < currentYear || (year == currentYear && month < currentMonth)) {
                                      return "Card expired";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: isSaved,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isSaved = newValue!;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                          const Text(
                            "Save credit card information",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff8E8E93),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      ContinueButton(
                        onPressed: _processCheckout,
                        txt: "Save & Pay",
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final bool hasImage;
  final String? image;
  final double? width;
  final bool hasWidth;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.image,
    this.hasImage = false,
    this.width,
    this.hasWidth = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: hasWidth ? width : double.infinity,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: label,
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xff8E8E93)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffD9D9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: hasImage && image != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    image!,
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.credit_card),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2 && !newText.contains('/')) {
        buffer.write('/');
      }
      buffer.write(newText[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
