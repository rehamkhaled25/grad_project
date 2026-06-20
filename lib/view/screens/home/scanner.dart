import 'dart:io'; // required for File
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:graduation_project/models/food_model.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/view/meal_prompts/fix_results.dart';
import 'package:graduation_project/view/meal_prompts/hidden.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/view/screens/payment/CameraAiUpgrade.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodScannerScreen extends StatefulWidget {
  final String? mealType;
  const FoodScannerScreen({super.key, this.mealType});

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
  bool _isPremium = false;
  final TextEditingController _barcodeController = TextEditingController();
  Timer? _popupTimer;
  String? _hiddenIngredients;
  bool _hasPromptedForHidden = false;

  // Stores the path of the last captured/picked image
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
    _initializeCamera();
    _popupTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_hasPromptedForHidden) {
        _hasPromptedForHidden = true;
        showDialog<String>(
          context: context,
          barrierColor: Colors.black54,
          builder: (context) => const HiddenIngredientsPage(),
        ).then((value) {
          if (value != null && value.isNotEmpty) {
            _hiddenIngredients = value;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    _controller?.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await ApiService().getCurrentUserEmail() ?? '';
    final prefix = email.isNotEmpty ? '${email}_' : '';
    setState(() {
      _isPremium = prefs.getBool('${prefix}premium_active') ?? false;
    });
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
    _popupTimer?.cancel();

    if (!_hasPromptedForHidden) {
      _hasPromptedForHidden = true;
      final value = await showDialog<String>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => const HiddenIngredientsPage(),
      );
      if (value != null && value.isNotEmpty) {
        _hiddenIngredients = value;
      }
    }

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

      // Step 2: Analyze the scanned food with hidden ingredients as context
      final analyzeResult = await _foodService.analyzeFood(scanId, context: _hiddenIngredients);

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
        imagePath: _currentImagePath,
        scanId: scanId,
        mealType: widget.mealType,
      ),
    );
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

          if (_activeMode != "Barcode") ...[
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
          ],

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
                Image.asset(
                  'assets/images/nutra_logo.png',
                  height: 26,
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Barcode search overlay
          if (_activeMode == "Barcode")
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildBarcodeSearchCard(),
                  ),
                ),
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
                  if (_activeMode != "Barcode")
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
        if (label == "Search") {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.push('/log', extra: widget.mealType);
          }
        } else {
          if (!_isPremium) {
            context.push('/trialSubscriptionPage', extra: {
              'id': 1,
              'name': 'Monthly Premium',
              'price': 9.99,
              'period': 'month',
            }).then((_) => _loadPremiumStatus());
            return;
          }

          if (label == "Gallery") {
            _pickFromGallery();
          } else {
            setState(() {
              _activeMode = label;
            });
          }
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

  Widget _buildBarcodeSearchCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD90C0C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.barcode_reader, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barcode Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Enter a code to fetch nutrition info',
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
          TextField(
            controller: _barcodeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter barcode number...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD90C0C)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Test Presets:',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip('Nutella', '3017620422003'),
              _buildPresetChip('Coca Cola', '5449000000996'),
              _buildPresetChip('USDA Product', '004800120120'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final code = _barcodeController.text.trim();
                final cleanCode = code.replaceAll(RegExp(r'\D'), '');
                if (cleanCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid barcode'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                context.push(
                  '/servingsDatabase',
                  extra: {
                    'source': 'open_food_facts',
                    'barcode': cleanCode,
                    'mealType': widget.mealType,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD90C0C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String code) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.08),
      side: BorderSide(color: Colors.white.withOpacity(0.05)),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      onPressed: () {
        _barcodeController.text = code;
        context.push(
          '/servingsDatabase',
          extra: {
            'source': 'open_food_facts',
            'barcode': code,
            'mealType': widget.mealType,
          },
        );
      },
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
  final String? mealType;

  const _NutritionResultSheet({
    required this.report,
    this.imagePath,
    this.scanId,
    this.mealType,
  });

  @override
  State<_NutritionResultSheet> createState() => _NutritionResultSheetState();
}

class _NutritionResultSheetState extends State<_NutritionResultSheet> {
  int _quantity = 1;
  bool _isLogging = false;
  bool _isReAnalyzing = false;
  final FoodService _foodService = FoodService();
  late NutritionReport _currentReport;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  // Scaled values (macro‑only for simplicity; you can extend to micronutrients)
  double get scaledCalories => _currentReport.totalCalories * _quantity;
  double get scaledProtein => _currentReport.totalProtein * _quantity;
  double get scaledCarbs => _currentReport.totalCarbs * _quantity;
  double get scaledFat => _currentReport.totalFat * _quantity;
  double? get scaledSugar => _currentReport.sugar != null ? _currentReport.sugar! * _quantity : null;
  int? get scaledSodium => _currentReport.sodium != null ? _currentReport.sodium! * _quantity : null;

  Future<void> _logFood() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    try {
      final data = <String, dynamic>{
        'log_time': DateTime.now().toIso8601String(),
      };
      if (widget.scanId != null) {
        data['scan_id'] = widget.scanId;
        data['quantity'] = _quantity;
        if (widget.mealType != null) {
          data['meal_type'] = widget.mealType;
        }
      } else {
        data['food_name'] = _currentReport.mealName;
        data['calories'] = scaledCalories;
        data['protein'] = scaledProtein;
        data['carbs'] = scaledCarbs;
        data['fat'] = scaledFat;
        data['quantity'] = _quantity;
        if (widget.mealType != null) {
          data['meal_type'] = widget.mealType;
        }
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

  Future<void> _fixResults() async {
    final fixPrompt = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const FixResultsPage(),
    );

    if (fixPrompt == null || fixPrompt.trim().isEmpty) return;

    if (widget.scanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot fix results without a valid scan ID"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isReAnalyzing = true);

    try {
      final analyzeResult = await _foodService.analyzeFood(
        widget.scanId!,
        context: fixPrompt,
      );

      final nutritionData = analyzeResult['report'] ?? analyzeResult;
      final newReport = NutritionReport.fromJson(nutritionData as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _currentReport = newReport;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Results updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update results: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _currentReport;
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
                if (report.warning.isNotEmpty) ...[
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
                          report.warning,
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
                ],

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
                        report.glycemicIndex <= 55
                            ? "Low"
                            : (report.glycemicIndex <= 69 ? "Medium" : "High"),
                        report.glycemicIndex <= 55
                            ? Colors.green
                            : (report.glycemicIndex <= 69 ? Colors.orange : Colors.red),
                        tooltipMessage: "Glycemic Index (GI) measures how fast a food raises blood sugar.\n\n• Low GI (<=55): Digested slowly, stable energy.\n• Medium GI (56-69): Moderate response.\n• High GI (>=70): Rapid sugar spike.",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallMetric(
                        "Glycemic Load",
                        "${report.glycemicLoad}",
                        report.glycemicLoad <= 10
                            ? "Low"
                            : (report.glycemicLoad <= 19 ? "Medium" : "High"),
                        report.glycemicLoad <= 10
                            ? Colors.green
                            : (report.glycemicLoad <= 19 ? Colors.orange : Colors.red),
                        tooltipMessage: "Glycemic Load (GL) accounts for both the GI and carb portion size.\n\n• Low GL (<=10): Low blood sugar impact.\n• Medium GL (11-19): Moderate impact.\n• High GL (>=20): Heavy sugar load.",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallMetric(
                        "Sodium",
                        scaledSodium != null ? "${scaledSodium}mg" : "N/A",
                        "",
                        Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  report.glycemicIndex <= 55
                      ? "Low response - stable energy levels"
                      : (report.glycemicIndex <= 69
                          ? "Moderate response - pair with protein for control"
                          : "High response - potential spike; pair with protein, fat, or fiber"),
                  style: TextStyle(
                    color: report.glycemicIndex <= 55
                        ? Colors.green
                        : (report.glycemicIndex <= 69 ? Colors.orange : Colors.red),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
                        scaledSugar != null ? "${scaledSugar!.toStringAsFixed(1)}g" : "N/A",
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
                        report.magnesium != null ? "${report.magnesium}mg" : "N/A",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridCard("Calcium", report.calcium != null ? "${report.calcium}mg" : "N/A"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridCard("Fiber", report.fiber != null ? "${report.fiber}g" : "N/A"),
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
                const SizedBox(height: 20),

                if (report.hiddenIngredients.isNotEmpty) ...[
                  _buildHiddenIngredientsSection(report.hiddenIngredients),
                  const SizedBox(height: 20),
                ],

                // FIX RESULTS BUTTON NAVIGATION SHOULD BE HERE AND SHOULD BE STACKED UNTOP OF THIS PAGE
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isReAnalyzing ? null : _fixResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isReAnalyzing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
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
    Color valueColor, {
    String? tooltipMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tooltipMessage != null)
                Tooltip(
                  message: tooltipMessage,
                  triggerMode: TooltipTriggerMode.tap,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  preferBelow: false,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.info_outline,
                      size: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
            ],
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

  Widget _buildHiddenIngredientsSection(List<HiddenIngredientReport> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hidden Ingredients Analysis",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...list.map((ing) {
          final double scaledCal = ing.impactCalories * _quantity;
          final double scaledProt = ing.impactProtein * _quantity;
          final double scaledCarbs = ing.impactCarbs * _quantity;
          final double scaledFat = ing.impactFat * _quantity;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1E1),
              border: Border.all(
                color: const Color(0xFF8C0B0B),
                width: 0.3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.visibility_off_outlined, color: Color(0xFFD90C0C), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ing.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD90C0C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImpactMetric("Calories", "+${scaledCal.toStringAsFixed(0)} kcal"),
                      _buildImpactDivider(),
                      _buildImpactMetric("Protein", "+${scaledProt.toStringAsFixed(1)}g"),
                      _buildImpactDivider(),
                      _buildImpactMetric("Carbs", "+${scaledCarbs.toStringAsFixed(1)}g"),
                      _buildImpactDivider(),
                      _buildImpactMetric("Fats", "+${scaledFat.toStringAsFixed(1)}g"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (ing.impactExplanation.isNotEmpty) ...[
                  const Text(
                    "Intake Impact",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD90C0C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ing.impactExplanation,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                ],

                if (ing.generalInfo.isNotEmpty) ...[
                  const Text(
                    "About this Ingredient",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD90C0C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ing.generalInfo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildImpactMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFFD90C0C),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactDivider() {
    return Container(
      height: 20,
      width: 1,
      color: const Color(0xFF8C0B0B).withOpacity(0.3),
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
