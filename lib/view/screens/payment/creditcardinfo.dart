import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/payment_options.dart';

class Creditcardinfo extends StatefulWidget {
  const Creditcardinfo({super.key});

  @override
  State<Creditcardinfo> createState() => _CreditcardinfoState();
}

class _CreditcardinfoState extends State<Creditcardinfo> {
 
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
   
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                  ),
                  const Text(
                    "Payment method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                "      Name",
                style: TextStyle(fontSize: 16, color: Color(0xff8E8E93), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const CustomTextField(label: "What's your name ?"),
              
              SizedBox(height: screenHeight * 0.05), 
              const Text(
                "Choose Payment Method",
                style: TextStyle(color: Color(0xff8E8E93), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  custom_image_holder(img: "assets/images/mastercard-full-svgrepo-com 1.png"),
                  custom_image_holder(img: 'assets/images/paypal-svgrepo-com 1.png'),
                  custom_image_holder(img: 'assets/images/google-pay-svgrepo-com 2.png'),
                  custom_image_holder(img: 'assets/images/apple-pay-svgrepo-com 1.png'),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.07), 
              const Text(
                "Card Number",
                style: TextStyle(fontSize: 16, color: Color(0xff8E8E93), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const CustomTextField(
                label: "Enter your card number",
                hasImage: true,
                image: "assets/images/mastercard-full-svgrepo-com 1 (1).png",
              ),
              
              SizedBox(height: screenHeight * 0.06), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("CVV", style: TextStyle(fontSize: 16, color: Color(0xff8E8E93), fontWeight: FontWeight.bold)),
                        CustomTextField(label: "123"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Expires", style: TextStyle(fontSize: 16, color: Color(0xff8E8E93), fontWeight: FontWeight.bold)),
                        CustomTextField(label: "MM/YY"),
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
                    style: TextStyle(fontSize: 14, color: Color(0xff8E8E93), fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              ContinueButton(onPressed: () {}, txt: "Save")
            ],
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

  const CustomTextField({
    super.key,
    required this.label,
    this.image,
    this.hasImage = false,
    this.width,
    this.hasWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: hasWidth ? width : double.infinity,
      height: 55, 
      child: TextField(
        decoration: InputDecoration(
          hintText: label, 
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xff8E8E93)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffD9D9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          suffixIcon: hasImage && image != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(image!),
                )
              : null,
        ),
      ),
    );
  }
}