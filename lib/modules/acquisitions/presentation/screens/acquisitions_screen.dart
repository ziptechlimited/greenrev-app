import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/acquisition_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AcquisitionsScreen extends StatefulWidget {
  const AcquisitionsScreen({super.key});

  @override
  State<AcquisitionsScreen> createState() => _AcquisitionsScreenState();
}

class _AcquisitionsScreenState extends State<AcquisitionsScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  List<AcquisitionModel> _myRequests = [];
  bool _isLoadingRequests = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) return;

    setState(() => _isLoadingRequests = true);
    try {
      final res = await _apiClient.get('/api/v1/acquisition-requests');
      if (res != null && res['requests'] != null) {
        final List<dynamic> list = res['requests'];
        setState(() {
          _myRequests = list.map((item) => AcquisitionModel.fromJson(item)).toList();
        });
      }
    } catch (_) {
      // Handle error gracefully
    } finally {
      if (mounted) setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text('Please log in to submit vehicle acquisition requests.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final msg = 'Vehicle: ${_makeController.text} ${_modelController.text} (${_yearController.text}), Mileage: ${_mileageController.text}. Notes: ${_notesController.text}';
      
      // Submit valuation request
      await _apiClient.post(
        '/api/v1/acquisition-requests',
        body: {'message': msg},
      );

      if (!mounted) return;
      _makeController.clear();
      _modelController.clear();
      _yearController.clear();
      _mileageController.clear();
      _notesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text('Valuation request registered! Our acquisition desk will perform telemetry audit.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
      _fetchRequests();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e is ApiException ? e.message : 'Submission failed.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY REQUESTS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: safeImageProvider('/images/home/relinquish.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'INSTANT VALUATION & BUYBACK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SELL OR TRADE-IN YOUR VEHICLE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get competitive telemetry-audited offers for your electric vehicle directly from certified buyers & vendors.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSubtle, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!auth.isLoggedIn) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassBoxDecoration(),
                child: Column(
                  children: [
                    const Icon(Icons.lock_outline, color: AppTheme.accent, size: 36),
                    const SizedBox(height: 12),
                    const Text(
                      'AUTHENTICATION REQUIRED FOR VEHICLE SUBMISSION',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('LOGIN TO SUBMIT VEHICLE'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Valuation Request Form
              const Text(
                'SUBMIT VEHICLE FOR AUDIT',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassBoxDecoration(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _makeController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _inputDecoration('MAKE (e.g. Tesla)'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _inputDecoration('MODEL (e.g. Model S)'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('YEAR (e.g. 2023)'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _mileageController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _inputDecoration('MILEAGE (km)'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 2,
                        decoration: _inputDecoration('ADDITIONAL CONDITION NOTES'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRequest,
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : const Text('SUBMIT FOR VALUATION'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Active Requests
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MY REQUESTS',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.accent, size: 18),
                    onPressed: _fetchRequests,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingRequests)
                const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              else if (_myRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No active vehicle acquisition requests.', style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _myRequests.length,
                  itemBuilder: (context, index) {
                    final req = _myRequests[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassBoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.productName ?? 'Acquisition Request',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  req.status,
                                  style: const TextStyle(color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (req.message != null) ...[
                            const SizedBox(height: 8),
                            Text(req.message!, style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent)),
    );
  }
}
