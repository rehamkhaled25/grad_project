import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  String _activeMode = "Scan Food";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint('Image picked from gallery: ${image.path}');
        _processImage(image.path);
      }
    } catch (e) {
      debugPrint("Error picking from gallery: $e");
      _showErrorSnackBar("Failed to pick image from gallery");
    }
  }

  Future<void> _takePicture() async {
    try {
      _showLoadingDialog();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (context.mounted) Navigator.pop(context);

      if (image != null) {
        debugPrint('Image captured: ${image.path}');
        _processImage(image.path);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint("Error taking picture: $e");
      _showErrorSnackBar("Failed to take picture. Please try again.");
    }
  }

  void _processImage(String path) {
    _showLoadingDialog(message: "Analyzing food...");

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
        _showResultsBottomSheet({
          'name': 'Sample Food',
          'calories': 250,
          'protein': 15,
          'carbs': 30,
          'fat': 8,
        });
      }
    });
  }

  void _showLoadingDialog({String message = "Processing..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResultsBottomSheet(Map<String, dynamic> nutritionData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nutrition Facts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              nutritionData['name'] ?? 'Unknown Food',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.5,
                children: [
                  _buildNutritionCard(
                    'Calories',
                    '${nutritionData['calories']} kcal',
                    Colors.orange,
                    Icons.local_fire_department,
                  ),
                  _buildNutritionCard(
                    'Protein',
                    '${nutritionData['protein']} g',
                    Colors.blue,
                    Icons.fitness_center,
                  ),
                  _buildNutritionCard(
                    'Carbs',
                    '${nutritionData['carbs']} g',
                    Colors.green,
                    Icons.grass,
                  ),
                  _buildNutritionCard(
                    'Fat',
                    '${nutritionData['fat']} g',
                    Colors.red,
                    Icons.opacity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to daily log!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add to Daily Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 3D Camera Illustration Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.black,
                  Colors.blueGrey.shade800,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Camera lens rings
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // Main camera lens
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.blueGrey.shade700,
                          Colors.blueGrey.shade500,
                          Colors.blueGrey.shade700,
                          Colors.blueGrey.shade900,
                          Colors.blueGrey.shade700,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner lens
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.blueGrey.shade300,
                                Colors.blueGrey.shade600,
                                Colors.blueGrey.shade800,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),

                        // Lens reflection
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.4),
                                Colors.transparent,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 1.0],
                            ),
                          ),
                        ),

                        // Aperture blades
                        ...List.generate(8, (index) {
                          return Transform.rotate(
                            angle: (index * 45) * 3.14159 / 180,
                            child: Container(
                              width: 160,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        // Center dot (reflection)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Small floating elements (depth effect)
                ...List.generate(20, (index) {
                  final randomX = (index * 37) % 300 - 150;
                  final randomY = (index * 73) % 300 - 150;
                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + randomX,
                    top: MediaQuery.of(context).size.height / 2 + randomY,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1 + (index * 0.01)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Dark overlay to make UI elements visible
          Container(color: Colors.black.withOpacity(0.3)),

          // Top UI
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CircleAvatar(
                //   backgroundColor: Colors.black38,
                //   child: IconButton(
                //     icon: const Icon(Icons.close, color: Colors.white),
                //     onPressed: () => Navigator.pop(context),
                //   ),
                // ),
                Center(
                  child: const Text(
                    'logoipsum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Scanning box
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _activeMode == "Barcode"
                      ? Colors.yellow
                      : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _activeMode == "Barcode"
                      ? "Scan Barcode"
                      : "Place food in frame",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Navigation options
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionTab(Icons.restaurant, "Scan Food"),
                _buildOptionTab(Icons.qr_code_2, "Barcode"),
                _buildOptionTab(Icons.photo_library, "Gallery"),
              ],
            ),
          ),

          // Action button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _activeMode == "Gallery"
                    ? _pickFromGallery
                    : _takePicture,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _activeMode == "Gallery"
                          ? Icons.photo_library
                          : Icons.camera_alt,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTab(IconData icon, String label) {
    bool isActive = _activeMode == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeMode = label);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.black : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
