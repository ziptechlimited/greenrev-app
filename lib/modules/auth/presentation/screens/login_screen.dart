import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../home/presentation/screens/main_shell.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else if (mounted) {
      final msg = authProvider.errorMessage ?? 'Authentication failed';
      if (msg.toLowerCase().contains('email not verified') || msg.contains('EMAIL_NOT_VERIFIED')) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(email: _emailController.text.trim()),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Please enter your verification PIN to activate access.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -size.height * 0.2,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.08),
              ),
              child: Image(
                image: safeImageProvider('/images/home/showroom.jpeg'),
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image(
                          image: safeImageProvider('/logo2.png'),
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GREENREV',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              letterSpacing: 8,
                              fontWeight: FontWeight.w900,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PERFORMANCE AUTOMOTIVE ECOSYSTEM',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: AppTheme.textSubtle,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Email input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'EMAIL ADDRESS',
                          hintStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppTheme.textSubtle),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSubtle, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Email is required';
                          if (!RegExp(r'^.+@.+\..+$').hasMatch(value.trim())) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Password input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'SECURITY PASSWORD',
                          hintStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppTheme.textSubtle),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                          prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textSubtle, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textSubtle,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sign in button
                      Container(
                        decoration: AppTheme.accentGlowDecoration(radius: 16),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                )
                              : const Text('AUTHORIZE ACCESS'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign up navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "NEW CLIENT? ",
                            style: TextStyle(fontSize: 12, color: AppTheme.textSubtle, letterSpacing: 1.0),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              "REGISTER GATEWAY",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
