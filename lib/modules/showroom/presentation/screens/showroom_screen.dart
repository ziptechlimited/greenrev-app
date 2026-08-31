import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import 'compare_screen.dart';
import 'vehicle_details_screen.dart';

class ShowroomScreen extends StatefulWidget {
  const ShowroomScreen({super.key});

  @override
  State<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends State<ShowroomScreen> {
  final ApiClient _apiClient = ApiClient();
  List<ProductModel> _allVehicles = [];
  List<ProductModel> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedMake;
  final List<ProductModel> _compareList = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/api/v1/products?category=vehicle', requiresAuth: false);
      if (response != null && response['products'] != null) {
        final List<dynamic> productsList = response['products'];
        setState(() {
          _allVehicles = productsList.map((p) => ProductModel.fromJson(p)).toList();
          _filteredVehicles = List.from(_allVehicles);
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
        "id": "1",
        "name": "Mercedes-Benz G63 AMG",
        "make": "Mercedes-Benz",
        "category": "vehicle",
        "year": 2024,
        "mileage": "150 km",
        "price": "₦270,000,000",
        "priceValue": 270000000.0,
        "image": "/showcase_front.jpg",
        "specs": {"horsepower": 577, "transmission": "9-Speed Automatic", "0_100": 4.5, "topSpeed": "220 km/h"}
      },
      {
        "id": "2",
        "name": "Xiaomi SU7 Max",
        "make": "Xiaomi",
        "category": "vehicle",
        "year": 2024,
        "mileage": "0 km",
        "price": "₦67,500,000",
        "priceValue": 67500000.0,
        "image": "/showcase_side.jpg",
        "specs": {"horsepower": 673, "transmission": "Single-Speed Direct Drive", "0_100": 2.78, "topSpeed": "265 km/h"}
      },
      {
        "id": "3",
        "name": "Tesla Cybertruck",
        "make": "Tesla",
        "category": "vehicle",
        "year": 2024,
        "mileage": "300 km",
        "price": "₦180,000,000",
        "priceValue": 180000000.0,
        "image": "/showcase_rear.jpg",
        "specs": {"horsepower": 845, "transmission": "Single-Speed Direct Drive", "0_100": 2.6, "topSpeed": "209 km/h"}
      },
      {
        "id": "4",
        "name": "Toyota Land Cruiser 300",
        "make": "Toyota",
        "category": "vehicle",
        "year": 2022,
        "mileage": "12,000 km",
        "price": "₦165,000,000",
        "priceValue": 165000000.0,
        "image": "/images/home/showroom.jpeg",
        "specs": {"horsepower": 409, "transmission": "10-Speed Automatic", "0_100": 6.7, "topSpeed": "210 km/h"}
      }
    ];
    setState(() {
      _allVehicles = fallbackJson.map((p) => ProductModel.fromJson(p)).toList();
      _filteredVehicles = List.from(_allVehicles);
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredVehicles = _allVehicles.where((vehicle) {
        final matchesSearch = vehicle.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehicle.make.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesMake = _selectedMake == null || vehicle.make == _selectedMake;
        return matchesSearch && matchesMake;
      }).toList();
    });
  }

  void _toggleCompare(ProductModel vehicle) {
    setState(() {
      if (_compareList.any((v) => v.id == vehicle.id)) {
        _compareList.removeWhere((v) => v.id == vehicle.id);
      } else {
        if (_compareList.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum of 3 vehicles can be compared simultaneously.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _compareList.add(vehicle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final makes = _allVehicles.map((v) => v.make).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('THE SHOWROOM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVehicles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search showroom...',
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
                const SizedBox(width: 12),
                // Make filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButton<String?>(
                    value: _selectedMake,
                    underline: const SizedBox(),
                    hint: const Text('MAKE', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.bold)),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    dropdownColor: AppTheme.cardBg,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('ALL MAKES')),
                      ...makes.map((make) => DropdownMenuItem(value: make, child: Text(make.toUpperCase()))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedMake = val;
                        _applyFilter();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Compare Floating Overlay Bar
          if (_compareList.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glassBoxDecoration(color: AppTheme.accent.withValues(alpha: 0.06)),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${_compareList.length} VEHICLE(S) SELECTED',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CompareScreen(vehicles: _compareList),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'COMPARE SPECS',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading ? _buildShimmerGrid() : _buildVehicleGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleGrid() {
    if (_filteredVehicles.isEmpty) {
      return const Center(
        child: Text(
          'No vehicles match parameters.',
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
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        final isComparing = _compareList.any((v) => v.id == vehicle.id);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
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
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: safeImageProvider(vehicle.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Compare Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _toggleCompare(vehicle),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: isComparing ? AppTheme.accent : Colors.black54,
                            child: Icon(
                              isComparing ? Icons.check : Icons.compare_arrows,
                              color: isComparing ? Colors.black : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.make.toUpperCase(),
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${vehicle.year} • ${vehicle.mileage ?? "0 km"}',
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.price,
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
        childAspectRatio: 0.72,
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
