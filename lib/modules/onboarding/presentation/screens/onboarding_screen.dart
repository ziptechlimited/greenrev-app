import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/state/auth_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/main_shell.dart';

class OnboardingItem {
  final String title;
  final String category;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.category,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      category: '01 / THE SHOWROOM',
      title: 'Digital Automotive Ecosystem',
      description: 'Explore verified vehicles, source essential parts, and connect with expert mechanics in one unified platform.',
      imagePath: '/images/home/showroom.jpeg',
    ),
    OnboardingItem(
      category: '02 / RELINQUISH MACHINE',
      title: 'Trade & Upgrade',
      description: 'Sell or trade-in your vehicle securely. Get instant valuations and connect with verified buyers in the GreenRev network.',
      imagePath: '/images/home/relinquish.jpeg',
    ),
    OnboardingItem(
      category: '03 / PARTS & PERFORMANCE',
      title: 'BESPOKE COMPONENTS',
      description: 'Bespoke dry carbon fiber aerodynamics, titanium valvetronic exhausts, center-lock wheels, and ceramic braking kits.',
      imagePath: '/images/home/parts.png',
    ),
    OnboardingItem(
      category: '04 / EXPERT CARE',
      title: 'CERTIFIED MECHANIC NETWORK',
      description: 'Connect directly with certified service centers and telemetry diagnostic specialists across major locations.',
      imagePath: '/images/home/expert.jpeg',
    ),
    OnboardingItem(
      category: '05 / SPECS COMPARISON',
      title: 'SIDE-BY-SIDE AUDIT',
      description: 'Audit performance parameters side-by-side: 0-100 km/h timers, horsepower outputs, torque ratings, and drive ratios.',
      imagePath: '/images/home/compare.jpeg',
    ),
    OnboardingItem(
      category: '06 / AI CONCIERGE',
      title: '24/7 INTELLIGENT ASSISTANT',
      description: 'Get instant interactive guidance on vehicle configurations, availability, specs, and parts compatibility.',
      imagePath: '/images/home/showroom.jpeg',
    ),
  ];

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}

    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final destination = auth.isLoggedIn ? const MainShell() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Carousel Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final item = _pages[index];
              return Stack(
                children: [
                  // Full Height Image
                  Positioned.fill(
                    child: Image(
                      image: safeImageProvider(item.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Dark Cinematic Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.3),
                            AppTheme.background.withValues(alpha: 0.95),
                            AppTheme.background,
                          ],
                          stops: const [0.0, 0.3, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content Body
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppTheme.textSubtle,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: size.height * 0.18), // Space for bottom controls
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Bar: Logo & Skip Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: safeImageProvider('/logo2.png'),
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: AppTheme.textSubtle,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar Controls: Page Indicators + Next Button
          Positioned(
            bottom: 40,
            left: 28,
            right: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(_pages.length, (index) {
                    final isSelected = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accent : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: AppTheme.accent,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                // Next / Complete Button
                GestureDetector(
                  onTap: _nextPage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: AppTheme.accentGlowDecoration(radius: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'ENTER GATEWAY' : 'NEXT',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
