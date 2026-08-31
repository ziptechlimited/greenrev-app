import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/state/cart_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isCheckingOut = false;

  void _processCheckout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final selectedCount = cartProvider.items.where((i) => i.isSelected).length;
    if (selectedCount == 0) return;

    if (!authProvider.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('AUTHENTICATION REQUIRED', style: TextStyle(color: AppTheme.accent, fontSize: 14, letterSpacing: 1.0)),
          content: const Text(
            'You must log in to dispatch vehicle acquisition and part procurement requests.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSubtle)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('PROCEED TO LOGIN'),
            ),
          ],
        ),
      );
      return;
    }

    final totalFormatted = cartProvider.totalPrice.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isCheckingOut = true);
    try {
      final selectedItems = cartProvider.items.where((i) => i.isSelected).toList();
      for (final item in selectedItems) {
        await _apiClient.post(
          '/api/v1/acquisition-requests',
          body: {
            'productId': item.product.id,
            'quantity': item.quantity,
            'message': 'Cart Checkout Order: ${item.product.name}',
          },
        );
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('ALL REQUESTS SENT', style: TextStyle(color: AppTheme.accent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your acquisition requests have been broadcasted successfully. The vendor clearing desk will dispatch telemetry details to your registered email.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Value: ₦$totalFormatted',
                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                cartProvider.clearSelected();
                Navigator.pop(dialogCtx);
              },
              child: const Text('PROCEED'),
            ),
          ],
        ),
      );
    } catch (e) {
      final msg = e is ApiException ? e.message : 'Checkout request failed. Please try again.';
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(msg),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final selectedCount = cart.items.where((i) => i.isSelected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YOUR SELECTION'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.textSubtle),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardBg,
                    title: const Text('CLEAR CART'),
                    content: const Text('Are you sure you want to remove all items from your selection?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                      ElevatedButton(
                        onPressed: () {
                          cart.clearAll();
                          Navigator.pop(context);
                        },
                        child: const Text('CLEAR ALL'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white12),
                  const SizedBox(height: 16),
                  const Text('Your selection is empty.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text('Explore the showroom or performance catalog.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: AppTheme.glassBoxDecoration(),
                        child: Row(
                          children: [
                            Checkbox(
                              value: item.isSelected,
                              activeColor: AppTheme.accent,
                              checkColor: Colors.black,
                              onChanged: (_) => cart.toggleSelection(item.product.id),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: safeImageProvider(item.product.image), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.make.toUpperCase(),
                                    style: const TextStyle(color: AppTheme.textSubtle, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.product.price,
                                    style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.white54),
                                  onPressed: () => cart.updateQuantity(item.product.id, item.quantity - 1),
                                ),
                                Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white54),
                                  onPressed: () => cart.updateQuantity(item.product.id, item.quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Checkout Footer Bar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: const Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SELECTED ($selectedCount ITEMS)',
                            style: const TextStyle(color: AppTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          Text(
                            '₦${cart.totalPrice.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}',
                            style: const TextStyle(color: AppTheme.accent, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: AppTheme.accentGlowDecoration(radius: 16),
                        child: ElevatedButton(
                          onPressed: _isCheckingOut || selectedCount == 0 ? null : _processCheckout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: _isCheckingOut
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                )
                              : const Text('SEND ACQUISITION REQUEST'),
                        ),
                      ),
                      const SizedBox(height: 110), // Increased height to clear floating bottom nav bar
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
