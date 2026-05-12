import 'dart:convert';
import 'dart:io'; // required for File
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:graduation_project/models/food_model.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:image_picker/image_picker.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String _activeMode = "Scan Food";
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  final FoodService _foodService = FoodService();

  // Stores the path of the last captured/picked image
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  Future<void> _processImageForAI(XFile imageFile) async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    try {
      // Store the image path BEFORE processing
      _currentImagePath = imageFile.path;

      // Step 1: Upload image to backend for scanning
      final scanResult = await _foodService.scanFood(File(imageFile.path));
      final scanObj = scanResult['scan'] ?? scanResult;
      final scanId = (scanObj['scan_id'] ?? scanObj['id'])?.toString();

      if (scanId == null || scanId.isEmpty) {
        throw "No scan_id returned from server";
      }

      // Step 2: Analyze the scanned food
      final analyzeResult = await _foodService.analyzeFood(scanId);

      // Step 3: Parse the nutrition data from the 'report' key
      final nutritionData = analyzeResult['report'] ?? analyzeResult;
      final report = NutritionReport.fromJson(nutritionData as Map<String, dynamic>);

      // Extract scan_id from the ui block if available
      final returnedScanId = analyzeResult['ui']?['scan_id']?.toString() ?? scanId;

      if (mounted) {
        _showResultsBottomSheet(report, scanId);
      }
    } catch (e) {
      debugPrint("AI_FAILURE_LOG: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Analysis Failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _onCapture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isAnalyzing)
      return;
    try {
      final image = await _controller!.takePicture();
      _processImageForAI(image);
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _processImageForAI(image);
    }
  }

  void _showResultsBottomSheet(NutritionReport report, [String? scanId]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NutritionResultSheet(
        report: report,
        imagePath: _currentImagePath, // pass the stored image path
        scanId: scanId,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          // Semi-transparent overlay with cut-out frame effect
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 100),
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanner frame corners
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              height: 280,
              width: 280,
              child: CustomPaint(painter: ScannerFramePainter()),
            ),
          ),

          // Top bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const Text(
                  "logoipsum",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeTab(Icons.crop_free, "Scan Food"),
                        _buildModeTab(Icons.barcode_reader, "Barcode"),
                        _buildModeTab(Icons.image_outlined, "Gallery"),
                        _buildModeTab(Icons.search, "Search"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _onCapture,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          height: 65,
                          width: 65,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeTab(IconData icon, String label) {
    bool isActive = _activeMode == label;
    return GestureDetector(
      onTap: () {
        if (label == "Gallery") {
          _pickFromGallery();
        } else {
          setState(() => _activeMode = label);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The bottom sheet – now StatefulWidget to handle quantity and image preview
// ---------------------------------------------------------------------------
class _NutritionResultSheet extends StatefulWidget {
  final NutritionReport report;
  final String? imagePath;
  final String? scanId;

  const _NutritionResultSheet({required this.report, this.imagePath, this.scanId});

  @override
  State<_NutritionResultSheet> createState() => _NutritionResultSheetState();
}

class _NutritionResultSheetState extends State<_NutritionResultSheet> {
  int _quantity = 1;
  bool _isLogging = false;
  final FoodService _foodService = FoodService();

  // Scaled values (macro‑only for simplicity; you can extend to micronutrients)
  double get scaledCalories => widget.report.totalCalories * _quantity;
  double get scaledProtein => widget.report.totalProtein * _quantity;
  double get scaledCarbs => widget.report.totalCarbs * _quantity;
  double get scaledFat => widget.report.totalFat * _quantity;
  double get scaledSugar => widget.report.sugar * _quantity;
  int get scaledSodium => widget.report.sodium * _quantity;

  Future<void> _logFood() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    try {
      final data = <String, dynamic>{};
      if (widget.scanId != null) {
        data['scan_id'] = widget.scanId;
        data['quantity'] = _quantity;
      } else {
        data['food_name'] = widget.report.mealName;
        data['calories'] = scaledCalories;
        data['protein'] = scaledProtein;
        data['carbs'] = scaledCarbs;
        data['fat'] = scaledFat;
        data['quantity'] = _quantity;
      }

      await _foodService.logFood(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Food logged successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to log food: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // ---------- IMAGE PREVIEW ----------
                if (widget.imagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.imagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Time & Bookmark
                Row(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${TimeOfDay.now().format(context)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title and Quantity Stepper (FIXED +/–)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.mealName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            child: const Icon(Icons.remove, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "$_quantity",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() => _quantity++),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Warning
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      // allows the text to shrink
                      child: Text(
                        report.warning.isNotEmpty
                            ? report.warning
                            : "Contains Avocado",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Calories Card (scaled)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Calories",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${scaledCalories.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Small Metrics (GI, GL, Sodium) – not scaled here, can be scaled if needed
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallMetric(
                        "Glycemic Index",
                        "${report.glycemicIndex}",
                        "Medium",
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallMetric(
                        "Glycemic Load",
                        "${report.glycemicLoad}",
                        "Medium",
                        Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallMetric(
                        "Sodium",
                        "${scaledSodium}mg",
                        "",
                        Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Moderate response - pair with protein for control",
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Macronutrients (scaled)
                const Text(
                  "Macronutrients",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        "Fats",
                        "${scaledFat.toStringAsFixed(1)}g",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridCard(
                        "Protein",
                        "${scaledProtein.toStringAsFixed(1)}g",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        "Carbohydrates",
                        "${scaledCarbs.toStringAsFixed(1)}g",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridCard(
                        "Sugar",
                        "${scaledSugar.toStringAsFixed(1)}g",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Micronutrients (unchanged, not scaled – can be extended)
                const Text(
                  "Micronutrients",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard(
                        "Magnesium",
                        "${report.magnesium}mg",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridCard("Calcium", "${report.calcium}mg"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard("Fiber", "${report.fiber}mg"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridCard("Vitamins", report.vitamins),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Health Score Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Health score",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${report.healthScore}/10",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: report.healthScore / 10,
                                minHeight: 6,
                                color: const Color(0xFF4CAF50),
                                backgroundColor: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Health Tip Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Health Tip",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${report.healthTip}"',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Fix results",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLogging ? null : _logFood,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLogging
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Done",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(
    String title,
    String value,
    String subtitle,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scanner frame painter (unchanged)
// ---------------------------------------------------------------------------
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const length = 40.0;

    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - length, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - length),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - length, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
