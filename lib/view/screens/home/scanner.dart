import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:graduation_project/models/food_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';




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
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
      if (apiKey.isEmpty) throw "API Key is missing from .env";

     
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
        ),
      );

      final imageBytes = await imageFile.readAsBytes();

      final prompt = [
        Content.multi([
          TextPart("""Analyze this food image and return a JSON object:
          {
            "meal_name": "name of food",
            "total_calories": integer,
            "total_protein": number,
            "total_carbs": number,
            "total_fat": number,
            "health_score": integer (1-10),
            "health_tip": "brief advice"
          }
          IMPORTANT: Return ONLY the JSON. No markdown blocks."""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(prompt);

      if (response.text == null || response.text!.isEmpty) {
        throw "AI returned an empty string.";
      }

      String cleanJson = response.text!.trim();
      if (cleanJson.startsWith("```")) {
        cleanJson = cleanJson.replaceAll(RegExp(r'```json|```'), '').trim();
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      final report = NutritionReport.fromJson(data);

      if (mounted) {
        _showResultsBottomSheet(report);
      }
    } catch (e) {
      debugPrint("AI_FAILURE_LOG: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analysis Failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _onCapture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isAnalyzing) return;
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

  void _showResultsBottomSheet(NutritionReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NutritionResultSheet(report: report),
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

     
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(decoration: const BoxDecoration(color: Colors.transparent)),
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

       
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              height: 280,
              width: 280,
              child: CustomPaint(painter: ScannerFramePainter()),
            ),
          ),

          
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

          // 5. Bottom Controls
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


class _NutritionResultSheet extends StatelessWidget {
  final NutritionReport report;
  const _NutritionResultSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text("Just now", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  report.mealName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

               
                _buildStatTile(
                  "Calories",
                  "${report.totalCalories}",
                  Icons.local_fire_department,
                  Colors.orange,
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroTile("Protein", "${report.totalProtein}g", Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroTile("Carbs", "${report.totalCarbs}g", Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroTile("Fats", "${report.totalFat}g", Colors.blue),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                const Text(
                  "Health score",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: report.healthScore / 10,
                    minHeight: 10,
                    color: report.healthScore > 6 ? Colors.green : Colors.orange,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        report.healthTip,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
               
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                        
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Fix results", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Done"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

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
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}