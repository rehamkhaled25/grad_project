import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String assetIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? toggleObscure;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.assetIcon,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.toggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E7E9)),
          ),
          child: Row(
            children: [
              Image.asset(
                assetIcon,
                height: 24,
                width: 24,
                color: Colors.black,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: isPassword ? obscureText : false,
                  keyboardType: keyboardType,
                  validator: validator,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    suffixIcon: isPassword
                        ? IconButton(
                            icon: Image.asset(
                              obscureText
                                  ? 'assets/images/Show.png'
                                  : 'assets/images/hide.png', // dynamic icon
                              height: 24,
                              width: 24,
                            ),
                            onPressed: toggleObscure,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
