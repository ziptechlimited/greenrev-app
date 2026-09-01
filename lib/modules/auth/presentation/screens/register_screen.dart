import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../settings/presentation/screens/privacy_screen.dart';
import '../../../settings/presentation/screens/terms_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _garageController = TextEditingController();
  
  String _selectedRole = 'customer';
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _garageController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      companyName: _selectedRole == 'vendor' ? _companyController.text.trim() : null,
      garageName: _selectedRole == 'mechanic' ? _garageController.text.trim() : null,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: _emailController.text.trim()),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            authProvider.errorMessage ?? 'Registration failed',
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
        title: const Text('CREATE ACCOUNT'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Image(
                          image: safeImageProvider('/logo2.png'),
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Text(
                      'ESTABLISH GATEWAY ACCESS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your specialized ecosystem role and input credentials.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSubtle),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Role Picker Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      dropdownColor: AppTheme.cardBg,
                      decoration: InputDecoration(
                        labelText: 'ECOSYSTEM ROLE',
                        labelStyle: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppTheme.accent),
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
                      ),
                      items: const [
                        DropdownMenuItem(value: 'customer', child: Text('CLIENT (BUYER & COLLECTOR)')),
                        DropdownMenuItem(value: 'vendor', child: Text('AUTOMOTIVE VENDOR')),
                        DropdownMenuItem(value: 'mechanic', child: Text('EXPERT / SPECIALIST')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRole = val);
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'FULL NAME',
                        hintStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppTheme.textSubtle),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.03),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                        prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSubtle, size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Conditional: Company Name
                    if (_selectedRole == 'vendor') ...[
                      TextFormField(
                        controller: _companyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'COMPANY / BUSINESS NAME',
                          hintStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppTheme.textSubtle),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                          prefixIcon: const Icon(Icons.business_outlined, color: AppTheme.textSubtle, size: 20),
                        ),
                        validator: (value) {
                          if (_selectedRole == 'vendor' && (value == null || value.trim().isEmpty)) {
                            return 'Company name is required for vendors';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Conditional: Garage Name
                    if (_selectedRole == 'mechanic') ...[
                      TextFormField(
                        controller: _garageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'GARAGE / WORKSHOP NAME',
                          hintStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, color: AppTheme.textSubtle),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                          prefixIcon: const Icon(Icons.build_circle_outlined, color: AppTheme.textSubtle, size: 20),
                        ),
                        validator: (value) {
                          if (_selectedRole == 'mechanic' && (value == null || value.trim().isEmpty)) {
                            return 'Garage name is required for mechanics';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
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
                        if (value.length < 8) return 'Password must be at least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            activeColor: AppTheme.accent,
                            checkColor: Colors.black,
                            side: const BorderSide(color: Colors.white54),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _agreedToTerms = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: const TextStyle(color: AppTheme.accent, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfUseScreen()));
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(color: AppTheme.accent, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Register Button
                    Container(
                      decoration: AppTheme.accentGlowDecoration(radius: 16),
                      child: ElevatedButton(
                        onPressed: (isLoading || !_agreedToTerms) ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text('INITIALIZE ACCESS'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
