import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'dart:async';

class DatabaseSearch extends StatefulWidget {
  const DatabaseSearch({super.key});

  @override
  State<DatabaseSearch> createState() => _DatabaseSearchState();
}

class _DatabaseSearchState extends State<DatabaseSearch> {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FoodService _foodService = FoodService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  final List<String> _tabLabels = ["All", "My meals", "My foods", "Saved Scans"];
  final List<String> _tabKeys = ["all", "my_meals", "my_foods", "saved_scans"];

  @override
  void initState() {
    super.initState();
    _performSearch(''); // Load default results
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final tab = _tabKeys[selectedTabIndex];
      final response = await _foodService.searchFood(query, tab: tab);
      final List rawResults = response['results'] ?? [];
      setState(() {
        _results = rawResults.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    children: [
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Food Database",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        onPressed: () {
                          context.push('/foodScanner');
                        },
                        icon: Image.asset("assets/images/scan_ic.png"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "What are you looking for?",
                      hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xffEBEBEB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabLabels.length, (index) {
                    return _buildTab(_tabLabels[index], index);
                  }),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  "No results found",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _results[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _FoodItemCard(item: item),
                );
              }, childCount: _results.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
        _performSearch(_searchController.text);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xffFF0F3C) : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _FoodItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item['food_name'] ?? item['meal_name'] ?? 'Unknown';
    final calories = item['calories'] ?? 0;
    final imageUrl = item['image_url'];
    final source = item['source'] ?? '';

    return GestureDetector(
      onTap: () {
        // Navigate to servings page with the food data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ServingsFromSearch(foodData: item),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          width: 334,
          height: 66,
          decoration: BoxDecoration(
            color: const Color(0xffEBEBEB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: Row(
              children: [
                if (imageUrl != null && imageUrl.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl.toString().startsWith('http')
                          ? imageUrl.toString()
                          : '${ApiService.baseUrl}$imageUrl',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/images/pancakes.png', width: 46, height: 46),
                    ),
                  )
                else
                  Image.asset('assets/images/pancakes.png', width: 46, height: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$name",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Image(
                            image: AssetImage(
                              'assets/images/flame bta3et saf7et el database.png',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(calories is num) ? calories.toStringAsFixed(0) : calories} cal",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple inline screen that shows when tapping a search result
class _ServingsFromSearch extends StatelessWidget {
  final Map<String, dynamic> foodData;
  const _ServingsFromSearch({required this.foodData});

  @override
  Widget build(BuildContext context) {
    final name = foodData['food_name'] ?? foodData['meal_name'] ?? 'Food';
    final calories = foodData['calories'] ?? 0;
    final protein = foodData['protein'] ?? 0;
    final carbs = foodData['carbs'] ?? 0;
    final fats = foodData['fats'] ?? foodData['fat'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        title: Text("$name"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$name", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${(calories is num) ? calories.toStringAsFixed(0) : calories} calories"),
                  const Divider(height: 30),
                  _row("Protein", "${(protein is num) ? protein.toStringAsFixed(1) : protein}g"),
                  _row("Carbs", "${(carbs is num) ? carbs.toStringAsFixed(1) : carbs}g"),
                  _row("Fats", "${(fats is num) ? fats.toStringAsFixed(1) : fats}g"),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                try {
                  await FoodService().logFood({
                    'food_name': name,
                    'calories': calories,
                    'protein': protein,
                    'carbs': carbs,
                    'fats': fats,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Food logged!"), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("Add food", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
