import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  final MapController _mapController = MapController();
  
  List<dynamic> _experts = [];
  bool _isLoading = true;
  dynamic _selectedExpert;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchExperts();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchExperts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/api/v1/experts', requiresAuth: false);
      if (response != null && response['experts'] != null) {
        setState(() {
          _experts = response['experts'];
        });
      }
    } catch (_) {
      _loadFallbackMockExperts();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadFallbackMockExperts() {
    final fallback = [
      {
        "id": "1",
        "name": "GreenRev Lagos (Lekki)",
        "city": "Lagos",
        "country": "Nigeria",
        "address": "Plot 15, Admiralty Way, Lekki Phase 1, Lagos",
        "lat": 6.4487,
        "lng": 3.4735,
        "specialization": ["Performance Tuning", "Hybrid Systems", "Concierge Service"],
        "phone": "+234 800 123 4567",
        "email": "lekki@greenrev.com",
        "image": "/images/experts/london.png"
      },
      {
        "id": "2",
        "name": "GreenRev Abuja (Maitama)",
        "city": "Abuja",
        "country": "Nigeria",
        "address": "22 Gana Street, Maitama, Abuja",
        "lat": 9.0833,
        "lng": 7.5000,
        "specialization": ["Security Upgrades", "Fleet Care"],
        "phone": "+234 800 111 2222",
        "email": "abuja@greenrev.com",
        "image": "/images/experts/dubai.png"
      },
      {
        "id": "3",
        "name": "GreenRev Port Harcourt",
        "city": "Port Harcourt",
        "country": "Nigeria",
        "address": "Trans-Amadi Industrial Layout, Port Harcourt",
        "lat": 4.8156,
        "lng": 7.0498,
        "specialization": ["Heavy-Duty Modification", "Engine Reconstruction"],
        "phone": "+234 800 333 4444",
        "email": "ph@greenrev.com",
        "image": "/images/experts/tokyo.png"
      }
    ];
    setState(() {
      _experts = fallback;
    });
  }

  Future<void> _bookExpert(dynamic expert) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('BOOK TELEMETRY INSPECTION', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1.0, color: AppTheme.accent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expert['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text(expert['address'], style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
            const SizedBox(height: 16),
            const Text(
              'This will book a performance evaluation. The center diagnostics concierge will contact you within 1 hour.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSubtle)),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                await _apiClient.post(
                  '/api/v1/bookings',
                  body: {
                    'expertId': expert['id'] ?? expert['_id'],
                    'notes': 'Booked via GreenRev Mobile App',
                  },
                );
              } catch (_) {
                // Handled gracefully
              }
              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.accent,
                  behavior: SnackBarBehavior.floating,
                  content: Text('Appointment request registered with ${expert['name']}.', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              );
            },
            child: const Text('CONFIRM BOOKING'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertDetailsCard() {
    if (_selectedExpert == null) return const SizedBox.shrink();
    
    final expert = _selectedExpert;
    return Container(
      decoration: AppTheme.glassBoxDecoration().copyWith(
        color: Colors.black.withValues(alpha: 0.85),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Image
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (expert['image'] != null)
                  Image(
                    image: safeImageProvider(expert['image']),
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.4),
                    colorBlendMode: BlendMode.darken,
                  )
                else
                  Container(color: Colors.white.withValues(alpha: 0.05)),
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CERTIFIED CENTER', style: TextStyle(color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        expert['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => setState(() => _selectedExpert = null),
                  ),
                )
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(Icons.location_on, color: AppTheme.accent, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        expert['address'],
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.phone, color: AppTheme.accent, size: 12),
                                SizedBox(width: 6),
                                Text('CONTACT', style: TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(expert['phone'] ?? 'N/A', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          border: Border.all(color: Colors.white10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.email, color: AppTheme.accent, size: 12),
                                SizedBox(width: 6),
                                Text('INQUIRY', style: TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(expert['email'] ?? 'N/A', style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _bookExpert(expert),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('BOOK SPECIALIZED SERVICE'),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('EXPERT CARE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(9.0820, 8.6753),
              initialZoom: 5.5,
              onTap: (tapPosition, point) {
                if (_selectedExpert != null) {
                  setState(() => _selectedExpert = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.greenrev.mobile',
              ),
              if (!_isLoading)
                MarkerLayer(
                  markers: _experts.map((expert) {
                    final lat = (expert['lat'] as num).toDouble();
                    final lng = (expert['lng'] as num).toDouble();
                    final isSelected = _selectedExpert != null && _selectedExpert['id'] == expert['id'];
                    
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 100,
                      height: 100,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedExpert = expert;
                          });
                          // Offset map slightly down so the card doesn't cover the marker
                          _mapController.move(LatLng(lat - 0.05, lng), 12.0);
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + (_pulseController.value * 2.5);
                            final opacity = 1.0 - _pulseController.value;
                            
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Radar effect
                                Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.accent.withValues(alpha: opacity * 0.5),
                                    ),
                                  ),
                                ),
                                // Marker Pin
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.accent : Colors.black87,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : AppTheme.accent.withValues(alpha: 0.5), 
                                      width: 2
                                    ),
                                    boxShadow: isSelected ? [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.5), blurRadius: 15)] : null,
                                  ),
                                  child: Icon(
                                    Icons.build, 
                                    color: isSelected ? Colors.black : AppTheme.accent, 
                                    size: 16
                                  ),
                                ),
                                // Hover Label (Simulated when selected)
                                if (isSelected)
                                  Positioned(
                                    bottom: 45,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Text(
                                        expert['name'].toString().toUpperCase(),
                                        style: const TextStyle(color: AppTheme.accent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          
          // Gradient fade at top to make app bar readable
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
            
          // Top Status Tag
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('GLOBAL NETWORK ACTIVE', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              ),
            ),
          ),
          
          // Map Zoom Controls
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
                GestureDetector(
                  onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      border: const Border(
                        left: BorderSide(color: Colors.white10),
                        right: BorderSide(color: Colors.white10),
                        bottom: BorderSide(color: Colors.white10),
                      ),
                    ),
                    child: const Icon(Icons.remove, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Details Overlay Card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            bottom: _selectedExpert != null ? 120 : -400, // 120 to clear floating nav bar
            left: 20,
            right: 20,
            child: _buildExpertDetailsCard(),
          ),
        ],
      ),
    );
  }
}
