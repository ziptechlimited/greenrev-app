import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/cart_provider.dart';
import '../../../../core/theme/theme.dart';

import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../mechanics/presentation/screens/mechanics_screen.dart';
import '../../../parts/presentation/screens/parts_screen.dart';
import '../../../showroom/presentation/screens/showroom_screen.dart';
import '../../../acquisitions/presentation/screens/acquisitions_screen.dart';
import '../../../../core/state/auth_provider.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShowroomScreen(),
    const PartsScreen(),
    const MechanicsScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          _buildFloatingTopAvatar(context),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  Widget _buildFloatingBottomBar() {
    final padding = MediaQuery.of(context).padding;
    final double bottomMargin = padding.bottom > 0 ? 12 : 20;

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: EdgeInsets.only(left: 20, right: 20, bottom: bottomMargin),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'HOME'),
                  _buildNavItem(1, Icons.directions_car_outlined, Icons.directions_car, 'SHOWROOM'),
                  _buildNavItem(2, Icons.build_circle_outlined, Icons.build_circle, 'PARTS'),
                  _buildNavItem(3, Icons.handyman_outlined, Icons.handyman, 'EXPERTS'),
                  _buildNavItem(4, Icons.shopping_cart_outlined, Icons.shopping_cart, 'CART'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _currentIndex == index;
    final iconColor = isSelected ? AppTheme.accent : AppTheme.textSubtle;
    final cartCount = Provider.of<CartProvider>(context).items.length;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isSelected ? solidIcon : outlineIcon,
                  color: iconColor,
                  size: isSelected ? 24 : 20,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: AppTheme.accent.withValues(alpha: 0.6),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 5 : 0,
                height: isSelected ? 5 : 0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent,
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ],
                ),
              )
            ],
          ),
          if (index == 4 && cartCount > 0)
            Positioned(
              right: 0,
              top: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingTopAvatar(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, right: 20.0),
          child: GestureDetector(
            onTap: () => _showUserDropdown(context, auth),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                child: Text(
                  (user.name ?? user.email).substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDropdown(BuildContext context, AuthProvider auth) {
    final user = auth.user;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
                    child: Text(
                      (user.name ?? user.email).substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'Anonymous Client',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppTheme.textSubtle,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              // Menu Options
              if (user.role == 'customer')
                _buildMenuOption(context, Icons.receipt_long, 'My Requests', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AcquisitionsScreen()),
                  );
                })
              else
                _buildMenuOption(context, Icons.dashboard_outlined, 'Dashboard', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dashboard features available via Web Console.'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                }),

              _buildMenuOption(context, Icons.mail_outline, 'My Messages', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message center opening...'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              _buildMenuOption(context, Icons.logout, 'Sign Out', () {
                Navigator.pop(context);
                auth.logout();
              }, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 20,
    );
  }
}
