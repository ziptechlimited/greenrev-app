import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme.dart';

class InquiryModalSheet extends StatefulWidget {
  final String? productId;
  final String? productName;

  const InquiryModalSheet({
    super.key,
    this.productId,
    this.productName,
  });

  static void show(BuildContext context, {String? productId, String? productName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InquiryModalSheet(
        productId: productId,
        productName: productName,
      ),
    );
  }

  @override
  State<InquiryModalSheet> createState() => _InquiryModalSheetState();
}

class _InquiryModalSheetState extends State<InquiryModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  late TextEditingController _messageController;
  final ApiClient _apiClient = ApiClient();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultMsg = widget.productName != null
        ? 'Inquiry regarding item: ${widget.productName}'
        : '';
    _messageController = TextEditingController(text: defaultMsg);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final body = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
      };

      await _apiClient.post('/api/v1/inquiries', body: body, requiresAuth: false);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Inquiry submitted successfully! Our desk will contact you shortly.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            e is ApiException ? e.message : 'Failed to submit inquiry. Please try again.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.support_agent, color: AppTheme.accent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BESPOKE INQUIRY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (widget.productName != null)
                          Text(
                            widget.productName!,
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('FULL NAME', Icons.person_outline),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('EMAIL ADDRESS', Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('PHONE NUMBER (OPTIONAL)', Icons.phone_outlined),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: _inputDecoration('MESSAGE OR SPECIFIC REQUIREMENTS', Icons.chat_bubble_outline),
                validator: (val) => val == null || val.trim().isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: AppTheme.accentGlowDecoration(radius: 16),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitInquiry,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Text('DISPATCH INQUIRY'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSubtle, fontSize: 10, letterSpacing: 1.0),
      prefixIcon: Icon(icon, color: AppTheme.textSubtle, size: 18),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.accent)),
    );
  }
}
