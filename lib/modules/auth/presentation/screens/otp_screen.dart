import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyEmail(
      widget.email,
      _pinController.text.trim(),
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('GATEWAY VALIDATED', style: TextStyle(color: AppTheme.accent)),
          content: const Text(
            'Your email address has been successfully verified. You may now authorize secure portal login.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('PROCEED', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            authProvider.errorMessage ?? 'Verification failed',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _resend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendVerification(widget.email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Verification passcode resent to your email.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            authProvider.errorMessage ?? 'Failed to resend PIN',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFY GATEWAY'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 64,
                  color: AppTheme.accent,
                ),
                const SizedBox(height: 32),
                const Text(
                  'ENTER PASSCODE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'A 6-digit access code was dispatched to:\n${widget.email}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSubtle, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Code Entry
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16.0,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      letterSpacing: 16.0,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'PIN is required';
                    if (value.trim().length != 6) return 'PIN must be exactly 6 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Verify Button
                Container(
                  decoration: AppTheme.accentGlowDecoration(radius: 16),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verify,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text('AUTHORIZE CODE'),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend Button
                TextButton(
                  onPressed: isLoading ? null : _resend,
                  child: const Text(
                    'RESEND ACCESS CODE',
                    style: TextStyle(
                      color: AppTheme.textSubtle,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
