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

class PartsDetailsScreen extends StatefulWidget {
  final ProductModel part;

  const PartsDetailsScreen({super.key, required this.part});

  @override
  State<PartsDetailsScreen> createState() => _PartsDetailsScreenState();
}

class _PartsDetailsScreenState extends State<PartsDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  int _quantity = 1;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;

  // Review submission
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
      final res = await _apiClient.get('/api/v1/products/${widget.part.id}/reviews', requiresAuth: false);
      if (res != null) {
        final List<dynamic> list = res is List ? res : (res['reviews'] ?? []);
        setState(() {
          _reviews = list.map((item) => ReviewModel.fromJson(item)).toList();
        });
      }
    } catch (_) {
      // Ignore fallback
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
        '/api/v1/products/${widget.part.id}/reviews',
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
    final size = MediaQuery.of(context).size;
    final fallbackImage = widget.part.image.isNotEmpty
        ? widget.part.image
        : '/images/parts/wing.png';

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image header
                SizedBox(
                  height: size.height * 0.42,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: safeImageProvider(fallbackImage),
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

                // Details Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.part.make.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.part.name,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'PERFORMANCE ACCURATED',
                            style: TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            widget.part.price,
                            style: const TextStyle(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Inquiry Button
                      OutlinedButton.icon(
                        onPressed: () {
                          InquiryModalSheet.show(context, productId: widget.part.id, productName: widget.part.name);
                        },
                        icon: const Icon(Icons.help_outline, size: 18, color: AppTheme.accent),
                        label: const Text('SUBMIT INQUIRY FOR THIS COMPONENT', style: TextStyle(color: AppTheme.accent, fontSize: 12, letterSpacing: 1.0)),
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
                        'PRODUCT DETAILS',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.part.description ??
                            'Aerodynamic composite materials engineered to deliver optimal road efficiency and balance. Formulated to reduce drag coefficient and increase downforce metrics.',
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Compatibility HUD
                      const Text(
                        'VEHICLE COMPATIBILITY HUD',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.part.specs?.compatibility ?? 'Universal / Multi-make alignment support',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quantity Selector Row
                      Row(
                        children: [
                          const Text(
                            'ORDER QUANTITY',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity -= 1);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                  onPressed: () {
                                    setState(() => _quantity += 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Product Reviews
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

                      if (_isLoadingReviews)
                        const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      else if (_reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('No reviews yet. Be the first to review this component!', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
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

                      const SizedBox(height: 120), // buffer for floating bottom bar
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

          // Floating Buy Button Bottom Bar
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
                          final cart = Provider.of<CartProvider>(context, listen: false);
                          for (int i = 0; i < _quantity; i++) {
                            cart.addItem(widget.part);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.accent,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                '$_quantity x ${widget.part.name} added to cart.',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('ADD TO CART'),
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
}
