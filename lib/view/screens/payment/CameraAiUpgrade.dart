import 'dart:ui';
import 'package:flutter/material.dart';

class Cameraaiupgrade extends StatelessWidget {
  const Cameraaiupgrade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/food_placeholder.png',
              fit: BoxFit.cover,
            ),
          ),

         
          SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/crown.png',
                            height: 22,
                            width: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Unlock all features',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

              
                    _buildFeatureRow('Unlimited meal plans'),
                    _buildFeatureRow('Advanced analytics'),
                    _buildFeatureRow('Custom macro tracking'),
                    _buildFeatureRow('Priority support'),
                    _buildFeatureRow('Ad-free experience'),

                    const SizedBox(height: 24),

                   
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to premium page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

         
        ],
      ),
    );
  }

  static Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFE50914), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}