import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/services/food_service.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/view/screens/payment/CameraAiUpgrade.dart';

import 'dart:async';

import 'package:graduation_project/view/screens/database/servings_database.dart';
 
class DatabaseSearch extends StatefulWidget {
  final String? mealType;
  const DatabaseSearch({super.key, this.mealType});
 
  @override
  State<DatabaseSearch> createState() => _DatabaseSearchState();
}
 
class _DatabaseSearchState extends State<DatabaseSearch> {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FoodService _foodService = FoodService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _isSuggestions = false;
  Timer? _debounce;
 
  final List<String> _tabLabels = ["All", "My foods", "Saved Scans"];
  final List<String> _tabKeys  = ["all", "my_foods", "saved_scans"];
 
  @override
  void initState() {
    super.initState();
    _performSearch('');
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
      final tab      = _tabKeys[selectedTabIndex];
      final response = await _foodService.searchFood(query, tab: tab);
      final List rawResults = response['results'] ?? [];
      
      List<Map<String, dynamic>> parsedResults = rawResults.cast<Map<String, dynamic>>();

      setState(() {
        _results   = parsedResults;
        _isSuggestions = response['is_suggestions'] == true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() {
        _results  = [];
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
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back,
                            size: 24, color: Colors.black),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Food Database",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final email = await ApiService().getCurrentUserEmail() ?? '';
                          final prefix = email.isNotEmpty ? '${email}_' : '';
                          final isSubscribed = prefs.getBool('${prefix}premium_active') ?? false;
                          if (isSubscribed) {
                            context.push('/foodScanner', extra: widget.mealType);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Cameraaiupgrade()),
                            );
                          }
                        },
                        icon: Image.asset("assets/images/scan_ic.png"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _AiScanBanner(mealType: widget.mealType),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "What are you looking for?",
                      hintStyle: const TextStyle(
                          color: Colors.black, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xffEBEBEB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
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
                  children: List.generate(
                    _tabLabels.length,
                    (index) => _buildTab(_tabLabels[index], index),
                  ),
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
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.restaurant_menu_rounded
                          : Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? "Search for any food"
                          : "No results found",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchController.text.isEmpty
                          ? "Try \"banana\", \"chicken breast\", or scan a barcode"
                          : "Try a different spelling or keyword",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[  
            // Section header
            if (_isSuggestions || (_searchController.text.isEmpty && selectedTabIndex == 0))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        _isSuggestions ? Icons.local_fire_department_rounded : Icons.history_rounded,
                        size: 20,
                        color: _isSuggestions ? const Color(0xffFF0F3C) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSuggestions ? "Popular Foods" : "Recent Foods",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _results[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _FoodItemCard(
                      item: item,
                      currentTab: _tabKeys[selectedTabIndex],
                      mealType: widget.mealType,
                      onSearchTap: (foodName) {
                        _searchController.text = foodName;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: foodName.length),
                        );
                        _performSearch(foodName);
                      },
                    ),
                  );
                },
                childCount: _results.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
 
  Widget _buildTab(String label, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTabIndex = index);
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
 
// ─────────────────────────────────────────────────────────────────────────────
// Food item card – tapping now opens ServingsDatabase (calls the real endpoint)
// ─────────────────────────────────────────────────────────────────────────────
class _FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String currentTab; // tells us which source to pass
  final String? mealType;
  final void Function(String foodName)? onSearchTap;
 
  const _FoodItemCard({required this.item, required this.currentTab, this.mealType, this.onSearchTap});
 
  /// Map the search tab to the source string the serving endpoint expects.
  String get _source {
    switch (currentTab) {
      case 'my_meals':
        return 'my_meals';
      case 'my_foods':
        return 'my_foods';
      case 'saved_scans':
        return 'saved_scans';
      default:
        // "all" tab – decide by what ids are present in the result
        if (item['fdc_id'] != null) return 'usda_fdc';
        if (item['barcode'] != null) return 'open_food_facts';
        if (item['scan_id'] != null) return 'saved_scans';
        return 'usda_fdc'; // fallback
    }
  }
 
  String? _getResolvedImageUrl(String name) {
    final rawUrl = item['image_url'] ?? item['image_path'];
    if (rawUrl == null || rawUrl.toString().trim().isEmpty || rawUrl.toString().trim() == 'null') return null;

    final urlStr = rawUrl.toString().trim();
    if (urlStr.startsWith('http')) return urlStr;

    if (urlStr.contains('\\') || urlStr.contains('/')) {
      final filename = urlStr.split('/').last.split('\\').last;
      return '${ApiService.baseUrl}/user/food/scans/image/$filename';
    }

    final base = ApiService.baseUrl.endsWith('/')
        ? ApiService.baseUrl
        : '${ApiService.baseUrl}/';
    final path = urlStr.startsWith('/') ? urlStr.substring(1) : urlStr;
    return '$base$path';
  }

  String _getFoodEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('salad')) return '🥗';
    if (n.contains('pizza')) return '🍕';
    if (n.contains('burger')) return '🍔';
    if (n.contains('pasta') || n.contains('noodle') || n.contains('spaghetti')) return '🍝';
    if (n.contains('rice')) return '🍚';
    if (n.contains('soup') || n.contains('stew')) return '🥣';
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    final name      = item['food_name'] ?? item['meal_name'] ?? 'Unknown';
    final calories  = item['calories'] ?? 0;
    final resolvedUrl = _getResolvedImageUrl(name);
 
    return GestureDetector(
      onTap: () {
        // Suggestion items trigger a search instead of navigating
        if (item['source'] == 'suggestion') {
          final foodName = item['food_name'] ?? '';
          if (onSearchTap != null && foodName.isNotEmpty) {
            onSearchTap!(foodName);
          }
          return;
        }
        context.push(
          '/servingsDatabase',
          extra: {
            'source':  _source,
            'fdcId':   item['fdc_id']?.toString(),
            'barcode': item['barcode']?.toString(),
            'scanId':  item['scan_id']?.toString(),
            'logId':   item['log_id']?.toString() ?? item['id']?.toString(),
            'mealType': mealType,
            'imageUrl': resolvedUrl,
            'item': item,
          },
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (resolvedUrl != null && resolvedUrl.isNotEmpty)
                        ? Image.network(
                            resolvedUrl,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                _getFoodEmoji(name),
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _getFoodEmoji(name),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
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
                                fontWeight: FontWeight.w500),
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

class _AiScanBanner extends StatefulWidget {
  final String? mealType;
  const _AiScanBanner({super.key, this.mealType});

  @override
  State<_AiScanBanner> createState() => _AiScanBannerState();
}

class _AiScanBannerState extends State<_AiScanBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Color(0xFF1E1E1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD90C0C).withOpacity(0.25),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final email = await ApiService().getCurrentUserEmail() ?? '';
              final prefix = email.isNotEmpty ? '${email}_' : '';
              final isSubscribed = prefs.getBool('${prefix}premium_active') ?? false;
              if (isSubscribed) {
                context.push('/foodScanner', extra: widget.mealType);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Cameraaiupgrade()),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "SCAN MEAL WITH AI",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD90C0C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "PRO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Instant calories, macros & hidden ingredients",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// _ServingsFromSearch has been intentionally removed.
// All food item taps now go to ServingsDatabase which calls
// GET /user/food/database/serving and shows fiber, sugar, sodium,
// log details, serving picker, and the Add food button.