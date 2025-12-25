import 'package:flutter/material.dart';

class SocialImageButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const SocialImageButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFDBD8D8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 28,
            width: 28,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
