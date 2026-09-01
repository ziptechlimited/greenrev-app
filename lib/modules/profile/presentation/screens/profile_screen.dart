import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../../settings/presentation/screens/privacy_screen.dart';
import '../../../settings/presentation/screens/terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();

  // Vendor Form Fields
  final _addProdFormKey = GlobalKey<FormState>();
  final _prodName = TextEditingController();
  final _prodMake = TextEditingController();
  final _prodPrice = TextEditingController();
  final _prodImg = TextEditingController();
  String _prodCategory = 'vehicle';
  bool _isSubmittingProduct = false;

  // Mechanic Settings
  bool _isAvailable = true;
  final _garageAddress = TextEditingController(text: 'Plot 15, Admiralty Way, Lekki, Lagos');

  @override
  void dispose() {
    _prodName.dispose();
    _prodMake.dispose();
    _prodPrice.dispose();
    _prodImg.dispose();
    _garageAddress.dispose();
    super.dispose();
  }

  Future<void> _submitNewProduct() async {
    if (!_addProdFormKey.currentState!.validate()) return;

    setState(() => _isSubmittingProduct = true);
    try {
      final body = {
        'name': _prodName.text.trim(),
        'make': _prodMake.text.trim(),
        'category': _prodCategory,
        'price': _prodPrice.text.trim(),
        'image': _prodImg.text.trim(),
      };

      await _apiClient.post('/api/v1/products', body: body);

      if (!mounted) return;
      Navigator.pop(context);

      _prodName.clear();
      _prodMake.clear();
      _prodPrice.clear();
      _prodImg.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text('Product catalog item published successfully!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e is ApiException ? e.message : 'Failed to publish product.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingProduct = false);
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('ADD ECOSYSTEM LISTING', style: TextStyle(color: AppTheme.accent, fontSize: 14, letterSpacing: 1.0)),
        content: Form(
          key: _addProdFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _prodCategory,
                  dropdownColor: AppTheme.cardBg,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'CATEGORY', labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                  items: const [
                    DropdownMenuItem(value: 'vehicle', child: Text('VEHICLE')),
                    DropdownMenuItem(value: 'part', child: Text('COMPONENT / PART')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _prodCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodName,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'NAME', labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodMake,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'MAKE / BRAND', labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Make is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodPrice,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'DISPLAY PRICE (e.g. ₦12,000,000)', labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Price is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prodImg,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'IMAGE URL', labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Image URL is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSubtle)),
          ),
          ElevatedButton(
            onPressed: _isSubmittingProduct ? null : _submitNewProduct,
            child: _isSubmittingProduct
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CLIENT CONSOLE'),
      ),
      body: auth.isLoggedIn
          ? _buildAuthenticatedProfile(context, auth)
          : _buildUnauthenticatedState(context),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_open_outlined,
              size: 64,
              color: AppTheme.textSubtle,
            ),
            const SizedBox(height: 24),
            const Text(
              'CONSOLE IS DEACTIVATED',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Access user telemetry dashboards, inventory listings, and custom tools.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSubtle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Container(
              decoration: AppTheme.accentGlowDecoration(radius: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('LOGIN PORTAL GATEWAY'),
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('REGISTER NEW SYSTEM ACCOUNT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, AuthProvider auth) {
    final user = auth.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glassBoxDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                  child: Text(
                    (user.name ?? user.email).substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppTheme.accent, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'ANONYMOUS CLIENT',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppTheme.textSubtle, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.role == 'admin'
                              ? Colors.redAccent.withValues(alpha: 0.1)
                              : user.role == 'vendor'
                                  ? Colors.blueAccent.withValues(alpha: 0.1)
                                  : user.role == 'mechanic'
                                      ? Colors.greenAccent.withValues(alpha: 0.1)
                                      : AppTheme.accent.withValues(alpha: 0.1),
                          border: Border.all(
                            color: user.role == 'admin'
                                ? Colors.redAccent.withValues(alpha: 0.3)
                                : user.role == 'vendor'
                                    ? Colors.blueAccent.withValues(alpha: 0.3)
                                    : user.role == 'mechanic'
                                        ? Colors.greenAccent.withValues(alpha: 0.3)
                                        : AppTheme.accent.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role == 'customer'
                              ? 'CLIENT'
                              : user.role == 'mechanic'
                                  ? 'EXPERT'
                                  : user.role.toUpperCase(),
                          style: TextStyle(
                            color: user.role == 'admin'
                                ? Colors.redAccent
                                : user.role == 'vendor'
                                    ? Colors.blueAccent
                                    : user.role == 'mechanic'
                                        ? Colors.greenAccent
                                        : AppTheme.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Context-aware dashboards
          if (user.role == 'vendor') _buildVendorDashboard(),
          if (user.role == 'mechanic') _buildMechanicDashboard(),
          if (user.role == 'admin') _buildAdminDashboard(),
          if (user.role == 'customer') _buildCustomerDashboard(),

          const SizedBox(height: 32),
          // Legal Links
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
              );
            },
            child: const Text('TERMS OF USE'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            child: const Text('PRIVACY POLICY'),
          ),
          const SizedBox(height: 12),
          // Logout button
          OutlinedButton(
            onPressed: () => auth.logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            child: const Text('DEAUTHORIZE SESSION (LOGOUT)'),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VENDOR UTILITY CONSOLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        // Stats
        Row(
          children: [
            Expanded(child: _buildDashboardMetric('4', 'ACTIVE ITEMS')),
            const SizedBox(width: 12),
            Expanded(child: _buildDashboardMetric('1.2K', 'IMPRESSIONS')),
            const SizedBox(width: 12),
            Expanded(child: _buildDashboardMetric('34', 'CHECKOUTS')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.accentGlowDecoration(radius: 16),
          child: ElevatedButton(
            onPressed: _showAddProductDialog,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.black, size: 18),
                SizedBox(width: 8),
                Text('UPLOADS NEW CATALOG PRODUCT'),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMechanicDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MECHANIC UTILITY CONSOLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassBoxDecoration(),
          child: Column(
            children: [
              // Availability Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DIAGNOSTICS STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isAvailable,
                    activeThumbColor: AppTheme.accent,
                    onChanged: (val) => setState(() => _isAvailable = val),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              // Address update
              TextField(
                controller: _garageAddress,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'GARAGE PHYSICAL ADDRESS',
                  labelStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 10),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.accent,
                      content: Text('Ecosystem status and location synchronized successfully.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
                child: const Text('SYNC COORDINATES'),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAdminDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ecosystem Control KPI metrics', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDashboardMetric('140', 'TOTAL USERS')),
            const SizedBox(width: 12),
            Expanded(child: _buildDashboardMetric('80', 'PRODUCTS')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDashboardMetric('24', 'PENDING APPROVALS')),
            const SizedBox(width: 12),
            Expanded(child: _buildDashboardMetric('₦8.4M', 'DAILY VOLUME')),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MY TRANSACTIONS HISTORY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassBoxDecoration(),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: AppTheme.accent),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AVATR 12 GT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Ordered on 2026-07-08', style: TextStyle(color: AppTheme.textSubtle, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDashboardMetric(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: AppTheme.glassBoxDecoration(),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSubtle, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
