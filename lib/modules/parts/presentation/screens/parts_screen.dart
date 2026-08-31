import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import 'parts_details_screen.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<ProductModel> _allParts = [];
  List<ProductModel> _filteredParts = [];
  bool _isLoading = true;
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  final List<String> _categories = [
    'ALL',
    'AERODYNAMICS',
    'EXHAUST',
    'WHEELS',
    'BRAKING',
    'INTERIOR',
    'ENGINE'
  ];

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/api/v1/products?category=part', requiresAuth: false);
      if (response != null && response['products'] != null) {
        final List<dynamic> productsList = response['products'];
        setState(() {
          _allParts = productsList.map((p) => ProductModel.fromJson(p)).toList();
          _filteredParts = List.from(_allParts);
        });
      }
    } catch (_) {
      _loadFallbackMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadFallbackMockData() {
    final fallbackJson = [
      {
        "id": "p1",
        "name": "Aureum Carbon Aero Wing",
        "make": "Aureum Performance",
        "category": "part",
        "price": "\$4,500",
        "priceValue": 4500.0,
        "description": "High-downforce dry carbon fiber wing, wind-tunnel tested for stability at 300km/h+.",
        "image": "/images/parts/wing.png",
        "specs": {"compatibility": "Mercedes-Benz G63, Avatr 12 GT"}
      },
      {
        "id": "p2",
        "name": "Titanium Valvetronic Exhaust",
        "make": "Akrapovič x GreenRev",
        "category": "part",
        "price": "\$8,200",
        "priceValue": 8200.0,
        "description": "Full titanium construction with wireless valve control for adjustable acoustic profile.",
        "image": "/images/home/parts.png",
        "specs": {"compatibility": "Audi R8, Porsche 911"}
      },
      {
        "id": "p3",
        "name": "21\" Forged Mono-Block Wheels",
        "make": "HRE Performance",
        "category": "part",
        "price": "\$12,000",
        "priceValue": 12000.0,
        "description": "Ultra-lightweight aerospace grade forged aluminum. Set of 4.",
        "image": "/images/home/parts.png",
        "specs": {"compatibility": "Universal"}
      }
    ];
    setState(() {
      _allParts = fallbackJson.map((p) => ProductModel.fromJson(p)).toList();
      _filteredParts = List.from(_allParts);
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredParts = _allParts.where((part) {
        final matchesSearch = part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            part.make.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCat = _selectedCategory == 'ALL' ||
            part.make.toUpperCase().contains(_selectedCategory) ||
            (_selectedCategory == 'AERODYNAMICS' && part.name.toLowerCase().contains('wing')) ||
            (_selectedCategory == 'EXHAUST' && part.name.toLowerCase().contains('exhaust')) ||
            (_selectedCategory == 'WHEELS' && part.name.toLowerCase().contains('wheels'));
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARTS & PERFORMANCE'),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search performance components...',
                hintStyle: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.03),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSubtle, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilter();
              },
            ),
          ),

          // Categories horizontal scroll list
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _applyFilter();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accent : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.accent : Colors.white10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading ? _buildShimmerGrid() : _buildPartsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsGrid() {
    if (_filteredParts.isEmpty) {
      return const Center(
        child: Text(
          'No custom accessories in collection.',
          style: TextStyle(color: AppTheme.textSubtle),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: _filteredParts.length,
      itemBuilder: (context, index) {
        final part = _filteredParts[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PartsDetailsScreen(part: part),
              ),
            );
          },
          child: Container(
            decoration: AppTheme.glassBoxDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: safeImageProvider(part.image.isNotEmpty ? part.image : '/images/parts/wing.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.make.toUpperCase(),
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        part.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        part.price,
                        style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white10,
          highlightColor: Colors.white24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}
