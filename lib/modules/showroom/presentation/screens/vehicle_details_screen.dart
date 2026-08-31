import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/review_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/state/cart_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../inquiries/presentation/widgets/inquiry_modal.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final ProductModel vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;

  // Review Form
  int _newRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final res = await _apiClient.get('/api/v1/products/${widget.vehicle.id}/reviews', requiresAuth: false);
      if (res != null) {
        final List<dynamic> list = res is List ? res : (res['reviews'] ?? []);
        setState(() {
          _reviews = list.map((item) => ReviewModel.fromJson(item)).toList();
        });
      }
    } catch (_) {
      // Handle review loading failure gracefully
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text('Please log in to leave a review.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      await _apiClient.post(
        '/api/v1/products/${widget.vehicle.id}/reviews',
        body: {
          'rating': _newRating,
          if (_commentController.text.trim().isNotEmpty) 'comment': _commentController.text.trim(),
        },
      );

      _commentController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text('Review submitted successfully!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
      _fetchReviews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e is ApiException ? e.message : 'Failed to submit review.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Scrolling content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vehicle Large Image Header
                SizedBox(
                  height: size.height * 0.45,
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.background,
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle Details content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vehicle.make.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          if (vehicle.color != null)
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(int.parse(vehicle.color!.hex.replaceFirst('#', '0xFF'))),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  vehicle.color!.name.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.name,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${vehicle.year} • ${vehicle.mileage ?? "0 km"}',
                            style: const TextStyle(color: AppTheme.textSubtle, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            vehicle.price,
                            style: const TextStyle(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quick Inquiry Button
                      OutlinedButton.icon(
                        onPressed: () {
                          InquiryModalSheet.show(context, productId: vehicle.id, productName: vehicle.name);
                        },
                        icon: const Icon(Icons.help_outline, size: 18, color: AppTheme.accent),
                        label: const Text('SUBMIT INQUIRY FOR THIS MACHINE', style: TextStyle(color: AppTheme.accent, fontSize: 12, letterSpacing: 1.0)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'OVERVIEW DESCRIPTION',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.description ??
                            'Rigorous engineering and aesthetic purity converge to define this masterpiece. Audited through our custom matrix, it represents the pinnacle of reliability and road control.',
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      // Specs Grid
                      const Text(
                        'PERFORMANCE HUD SPECIFICATIONS',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildSpecsGrid(vehicle),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Vendor information
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.business, color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('VERIFIED DEEP-MARKET VENDOR', style: TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Text(vehicle.vendorName ?? 'GreenRev Exclusive Vendor', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Product Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CUSTOMER REVIEWS & RATINGS',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          Text(
                            '${_reviews.length} REVIEW(S)',
                            style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Write a review card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassBoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ADD A VERIFIED REVIEW', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) {
                                final starRating = index + 1;
                                return GestureDetector(
                                  onTap: () => setState(() => _newRating = starRating),
                                  child: Icon(
                                    starRating <= _newRating ? Icons.star : Icons.star_border,
                                    color: AppTheme.accent,
                                    size: 22,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Share your performance or delivery feedback...',
                                hintStyle: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.03),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _isSubmittingReview ? null : _submitReview,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                                child: _isSubmittingReview
                                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                    : const Text('SUBMIT REVIEW', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List of existing reviews
                      if (_isLoadingReviews)
                        const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      else if (_reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('No reviews yet. Be the first to review this machine!', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
                        )
                      else
                        ..._reviews.map((rev) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: AppTheme.glassBoxDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rev.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < rev.rating ? Icons.star : Icons.star_border,
                                            color: AppTheme.accent,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rev.comment != null && rev.comment!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(rev.comment!, style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12, height: 1.3)),
                                  ],
                                ],
                              ),
                            )),

                      const SizedBox(height: 120), // buffer for floating bottom checkout bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Floating Add to Cart Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.9),
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: AppTheme.accentGlowDecoration(radius: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(vehicle);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.accent,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                '${vehicle.name} added to cart.',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                        child: const Text('ACQUIRE MACHINE (ADD TO CART)'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(ProductModel vehicle) {
    final specs = vehicle.specs;
    final horsepower = specs?.horsepower?.toString() ?? 'N/A';
    final transmission = specs?.transmission ?? 'N/A';
    final topSpeed = specs?.topSpeed ?? 'N/A';
    final torque = specs?.torque ?? 'N/A';
    final accel = specs?.acceleration != null ? '${specs!.acceleration}s' : 'N/A';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildSpecItem(Icons.speed, '0 - 100 KM/H', accel),
        _buildSpecItem(Icons.bolt, 'HORSEPOWER', horsepower),
        _buildSpecItem(Icons.settings, 'TRANSMISSION', transmission),
        _buildSpecItem(Icons.tire_repair, 'TORQUE RATIO', torque),
        _buildSpecItem(Icons.sports_score, 'TOP VELOCITY', topSpeed),
        _buildSpecItem(Icons.verified, 'STATUS', vehicle.inStock ? 'IN STOCK' : 'ORDERED'),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSubtle, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
