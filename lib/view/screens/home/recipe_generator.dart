import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:graduation_project/services/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/food_service.dart';

class RecipeGeneratorScreen extends StatefulWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  State<RecipeGeneratorScreen> createState() => _RecipeGeneratorScreenState();
}

class _RecipeGeneratorScreenState extends State<RecipeGeneratorScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  double _maxPrepTime = 30.0;
  
  final List<String> _goals = [
    "High Protein",
    "Low Carb",
    "Low Fat",
    "Quick Meal",
    "Vegan",
    "Vegetarian",
  ];
  final List<String> _selectedGoals = [];
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  Map<String, dynamic>? _generatedRecipe;
  List<Map<String, dynamic>> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _initGemini();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('ai_saved_recipes');
      if (savedJson != null) {
        final List<dynamic> decoded = jsonDecode(savedJson);
        setState(() {
          _savedRecipes = decoded.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint("Error loading saved recipes: $e");
    }
  }

  Future<void> _saveRecipe() async {
    if (_generatedRecipe == null) return;
    
    final title = _generatedRecipe!['title'] ?? 'Generated Recipe';
    final exists = _savedRecipes.any((r) => r['title'] == title);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Recipe is already saved!"),
          backgroundColor: Colors.blueAccent,
        ),
      );
      return;
    }

    setState(() {
      _savedRecipes.insert(0, _generatedRecipe!);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_saved_recipes', jsonEncode(_savedRecipes));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Recipe saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save recipe: $e"),
        backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRecipe(int index) async {
    setState(() {
      _savedRecipes.removeAt(index);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_saved_recipes', jsonEncode(_savedRecipes));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Recipe removed."),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      debugPrint("Error saving recipes after delete: $e");
    }
  }

  Future<void> _logRecipeAsMeal() async {
    if (_generatedRecipe == null) return;
    
    final title = _generatedRecipe!['title'] ?? 'Generated Recipe';
    final calories = _generatedRecipe!['calories'] ?? 0;
    
    final macros = _generatedRecipe!['macros'] ?? {};
    final proteinStr = macros['protein']?.toString() ?? '0';
    final carbsStr = macros['carbs']?.toString() ?? '0';
    final fatStr = macros['fat']?.toString() ?? '0';
    
    final double protein = double.tryParse(proteinStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final double carbs = double.tryParse(carbsStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final double fats = double.tryParse(fatStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    final mealType = await _showMealTypePicker();
    if (mealType == null) return;

    try {
      final Map<String, dynamic> payload = {
        'food_name': title,
        'calories': calories.toDouble(),
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'base_calories': calories.toDouble(),
        'base_protein': protein,
        'base_carbs': carbs,
        'base_fats': fats,
        'portion_multiplier': 1.0,
        'serving_name': '1 serving',
        'serving_size': 1.0,
        'meal_type': mealType,
        'ai_scan': false,
        'log_time': DateTime.now().toIso8601String(),
      };

      await FoodService().logFood(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Recipe logged to food diary!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to log recipe: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showMealTypePicker() {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final options = [
          ('Breakfast', 'breakfast', Icons.wb_sunny_outlined),
          ('Lunch',     'lunch',     Icons.lunch_dining_outlined),
          ('Dinner',    'dinner',    Icons.nights_stay_outlined),
          ('Snack',     'snack',     Icons.cookie_outlined),
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add to which meal?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) => ListTile(
                    leading: Icon(opt.$3, color: Colors.black),
                    title: Text(opt.$1,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.pop(context, opt.$2),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _initGemini() {
    if (GeminiService.apiKeys.isEmpty) {
      setState(() {
        _errorMessage = "Gemini API key is missing. Please configure GEMINI_API_KEY in your .env file.";
        _isInitialized = false;
      });
      return;
    }

    final generationConfig = GenerationConfig(
      responseMimeType: 'application/json',
      maxOutputTokens: 8000,
      responseSchema: Schema.object(
        properties: {
          'title': Schema.string(description: 'Recipe Name'),
          'prep_time': Schema.string(description: 'Prep & Cook time (e.g. 25 mins)'),
          'calories': Schema.integer(description: 'Estimated Calories'),
          'macros': Schema.object(
            properties: {
              'protein': Schema.string(description: 'Protein in grams (e.g. 25g)'),
              'carbs': Schema.string(description: 'Carbs in grams (e.g. 45g)'),
              'fat': Schema.string(description: 'Fat in grams (e.g. 12g)'),
            },
            requiredProperties: ['protein', 'carbs', 'fat'],
          ),
          'ingredients': Schema.array(
            items: Schema.string(),
            description: 'Ingredients list with amounts',
          ),
          'steps': Schema.array(
            items: Schema.string(),
            description: 'Numbered steps to make the recipe',
          ),
        },
        requiredProperties: ['title', 'prep_time', 'calories', 'macros', 'ingredients', 'steps'],
      ),
    );

    // Try building model to confirm setup
    final model = GeminiService.getModel(
      modelName: 'gemini-2.5-flash',
      generationConfig: generationConfig,
      systemInstruction: Content.system(
        "You are a professional chef and certified dietitian. Generate healthy recipes in JSON format matching the specified schema. Ensure all fields are filled, and recipe quantities and instructions are clear."
      ),
    );

    if (model == null) {
      setState(() {
        _errorMessage = "Failed to initialize Gemini model.";
        _isInitialized = false;
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _generateRecipe() async {
    final ingredients = _ingredientsController.text.trim();
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter at least some ingredients!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedRecipe = null;
    });

    final generationConfig = GenerationConfig(
      responseMimeType: 'application/json',
      maxOutputTokens: 8000,
      responseSchema: Schema.object(
        properties: {
          'title': Schema.string(description: 'Recipe Name'),
          'prep_time': Schema.string(description: 'Prep & Cook time (e.g. 25 mins)'),
          'calories': Schema.integer(description: 'Estimated Calories'),
          'macros': Schema.object(
            properties: {
              'protein': Schema.string(description: 'Protein in grams (e.g. 25g)'),
              'carbs': Schema.string(description: 'Carbs in grams (e.g. 45g)'),
              'fat': Schema.string(description: 'Fat in grams (e.g. 12g)'),
            },
            requiredProperties: ['protein', 'carbs', 'fat'],
          ),
          'ingredients': Schema.array(
            items: Schema.string(),
            description: 'Ingredients list with amounts',
          ),
          'steps': Schema.array(
            items: Schema.string(),
            description: 'Numbered steps to make the recipe',
          ),
        },
        requiredProperties: ['title', 'prep_time', 'calories', 'macros', 'ingredients', 'steps'],
      ),
    );

    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      final model = GeminiService.getModel(
        modelName: 'gemini-2.5-flash',
        generationConfig: generationConfig,
        systemInstruction: Content.system(
          "You are a professional chef and certified dietitian. Generate healthy recipes in JSON format matching the specified schema. Ensure all fields are filled, and recipe quantities and instructions are clear."
        ),
      );

      if (model == null) {
        setState(() {
          _errorMessage = "No Gemini API keys are configured.";
        });
        break;
      }

      final prompt = """
      Generate a healthy recipe using some or all of these ingredients: $ingredients.
      The recipe must align with the following goals: ${_selectedGoals.join(', ')}.
      The total prep + cook time must be under ${_maxPrepTime.round()} minutes.
      """;

      try {
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;
        if (text == null || text.isEmpty) {
          throw Exception("Empty response received from AI.");
        }

        debugPrint("Raw Gemini Response: $text");

        // Extract JSON from markdown code block if present (more robust than line-by-line checks)
        String cleanText = text.trim();
        final jsonRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
        final match = jsonRegex.firstMatch(cleanText);
        if (match != null) {
          cleanText = match.group(1)!.trim();
        } else {
          // If no markdown block, extract between the first '{' and last '}'
          final firstBrace = cleanText.indexOf('{');
          final lastBrace = cleanText.lastIndexOf('}');
          if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
            cleanText = cleanText.substring(firstBrace, lastBrace + 1);
          }
        }

        // Clean trailing commas (e.g. [1, 2,] or {a: 1,}) which make jsonDecode fail in Dart
        cleanText = cleanText.replaceAll(RegExp(r',\s*(\])'), ']');
        cleanText = cleanText.replaceAll(RegExp(r',\s*(\})'), '}');

        final parsed = jsonDecode(cleanText) as Map<String, dynamic>;
        setState(() {
          _generatedRecipe = parsed;
        });
        
        break; // Success! Exit loop.
      } catch (e) {
        attempts++;
        final errStr = e.toString().toLowerCase();
        final isQuota = errStr.contains("quota") ||
                        errStr.contains("exhausted") ||
                        errStr.contains("429") ||
                        errStr.contains("limit");

        if (isQuota && attempts < maxAttempts && GeminiService.apiKeys.length > 1) {
          debugPrint("Quota exceeded during recipe generation. Rotating and retrying... Attempt $attempts");
          GeminiService.rotateKey();
          continue; // Retry with next key
        }

        setState(() {
          _errorMessage = "Failed to generate recipe: $e. Please try again.";
        });
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 18,
              child: const Icon(Icons.restaurant_menu_rounded, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Recipe Maker",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Pantry-to-Plate Assistant",
                  style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: !_isInitialized
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage ?? "Initializing generator...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputForm(),
                  const SizedBox(height: 20),
                  if (_isLoading) _buildLoadingState(),
                  if (_errorMessage != null) _buildErrorState(),
                  if (_generatedRecipe != null) _buildRecipeDisplay(),
                  if (_generatedRecipe == null && !_isLoading) ...[
                    const SizedBox(height: 20),
                    _buildSavedRecipesList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's in your pantry?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Enter ingredients you want to use (e.g. chicken breast, spinach, sweet potato, olive oil)",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: const Color(0xffF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFD90C0C), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Nutrition Goals",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((goal) {
                final isSelected = _selectedGoals.contains(goal);
                return FilterChip(
                  label: Text(
                    goal,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFFE1E1) : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.black,
                  checkmarkColor: const Color(0xFFD90C0C),
                  backgroundColor: const Color(0xffF4F4F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGoals.add(goal);
                      } else {
                        _selectedGoals.remove(goal);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Max Prep & Cook Time",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
                ),
                Text(
                  "${_maxPrepTime.round()} mins",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color.fromARGB(255, 0, 0, 0),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: const Color.fromARGB(255, 0, 0, 0),
                overlayColor: const Color(0xFFFFE1E1).withOpacity(0.4),
              ),
              child: Slider(
                value: _maxPrepTime,
                min: 5.0,
                max: 90.0,
                divisions: 17,
                label: "${_maxPrepTime.round()} mins",
                onChanged: (value) {
                  setState(() {
                    _maxPrepTime = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color.fromARGB(255, 255, 255, 255)),
                    SizedBox(width: 10),
                    Text(
                      "Generate Recipe",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xFFD90C0C)),
            const SizedBox(height: 15),
            Text(
              "Creating a customized recipe...",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? "An error occurred",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDisplay() {
    if (_generatedRecipe == null) return const SizedBox.shrink();

    final title = _generatedRecipe!['title'] ?? 'Generated Recipe';
    final prepTime = _generatedRecipe!['prep_time'] ?? '';
    final calories = _generatedRecipe!['calories'] ?? 0;
    final macros = _generatedRecipe!['macros'] ?? {};
    final protein = macros['protein'] ?? 'N/A';
    final carbs = macros['carbs'] ?? 'N/A';
    final fat = macros['fat'] ?? 'N/A';
    
    final List<dynamic> rawIngredients = _generatedRecipe!['ingredients'] ?? [];
    final List<dynamic> rawSteps = _generatedRecipe!['steps'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Header Card
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
                      ),
                    ),
                    if (prepTime.toString().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "⏱️ $prepTime",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _generatedRecipe = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 10),
                // Macros Breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroMetric("Calories", "🔥 $calories kcal", Colors.black),
                    _buildMacroMetric("Protein", "🍗 $protein", Colors.green),
                    _buildMacroMetric("Carbs", "🍞 $carbs", Colors.blue),
                    _buildMacroMetric("Fat", "🥑 $fat", Colors.amber),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveRecipe,
                        icon: const Icon(Icons.bookmark_border_rounded, size: 18, color: Color(0xFFD90C0C)),
                        label: const Text("Save Recipe", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: const Color(0xFFFFE1E1),
                          side: const BorderSide(color: Color(0xFFD90C0C), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _logRecipeAsMeal,
                        icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFFD90C0C)),
                        label: const Text("Log to Diary", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: const Color(0xFFFFE1E1),
                          side: const BorderSide(color: Color(0xFFD90C0C), width: 1.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Ingredients Card
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_basket_rounded, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "Ingredients Needed",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rawIngredients.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                          Expanded(
                            child: Text(
                              rawIngredients[index].toString(),
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Steps Card
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_list_numbered_rounded, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "Instructions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rawSteps.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rawSteps[index].toString(),
                              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSavedRecipesList() {
    if (_savedRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Saved Recipes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1E1B39)),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedRecipes.length,
          itemBuilder: (context, index) {
            final recipe = _savedRecipes[index];
            final title = recipe['title'] ?? 'Saved Recipe';
            final prepTime = recipe['prep_time'] ?? '';
            final calories = recipe['calories'] ?? 0;

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: const Icon(Icons.restaurant_rounded, color: Colors.black),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  "${prepTime.isNotEmpty ? '$prepTime • ' : ''}$calories kcal",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => _deleteRecipe(index),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _generatedRecipe = recipe;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMacroMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
