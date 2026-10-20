import 'dart:math' as math;

import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Beranda Screen')),
    Center(child: Text('Menu Screen')),
    Center(child: Text('VIP Screen')),
    Center(child: Text('Merch Screen')),
    Center(child: Text('Saya Screen')),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 88,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TAB 1: BERANDA - Active memiliki background krem
              _navItem(
                0,
                Icons.home_outlined,
                Icons.home,
                'Beranda',
                _selectedIndex == 0,
              ),
              
              // TAB 2: MENU - Active memiliki background krem
              _navItem(
                1,
                Icons.book_outlined,
                Icons.book,
                'Menu',
                _selectedIndex == 1,
              ),
              
              // TAB 3: VIP - SPESIAL: hexagon badge + heart (wajib kitapertahankan)
              // Tetapi juga mendapat background krem saat active
              _vipNavItem(_selectedIndex == 3),
              
              // TAB 4: MERCH - Active memiliki background krem
              _navItem(
                2,
                Icons.shopping_bag_outlined,
                Icons.shopping_bag,
                'Merch',
                _selectedIndex == 2,
              ),
              
              // TAB 5: SAYA - Active memiliki background krem
              _navItem(
                3,
                Icons.person_outlined,
                Icons.person,
                'Saya',
                _selectedIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NAV ITEM UMUM - Setiap active mendapat background krem lingkaran
  Widget _navItem(
    int index,
    IconData iconOut,
    IconData iconSel,
    String label,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        // 56x56 dengan radius 28 = lingkaran sempurna
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          // **SETIAP ACTIVE TAB HARUS PUNYA BACKGROUND KREM**
          color: isActive ? const Color(0xFFFDE9EB) : Colors.transparent,
          shape: BoxShape.circle, // Pastikan bentuk lingkaran
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconSel : iconOut,
              size: 24,
              color: isActive ? const Color(0xFFBD1E2D) : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFFBD1E2D) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // VIP NAV ITEM - Mempertahankan desain hexagon + heart,
  // TAPI tetap mendapatkan background krem saat active
  Widget _vipNavItem(bool isActive) {
    return GestureDetector(
      onTap: () => _onItemTapped(3),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          // **VIP JUGA PUNYA BACKGROUND KREM SAAT ACTIVE**
          color: isActive ? const Color(0xFFFDE9EB) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hexagon badge dengan heart di tengah
            Stack(
              children: [
                // Hexagon outline
                Icon(
                  Icons.star_outlined,
                  size: 28,
                  color: isActive ? const Color(0xFFBD1E2D) : const Color(0xFF6B7280),
                ),
                // Center heart
                Positioned(
                  child: Icon(
                    Icons.favorite,
                    size: 18,
                    color: isActive 
                      ? const Color(0xFFBD1E2D) 
                      : const Color(0xFFE879F9), // pastel pink
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'VIP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBD1E2D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper untuk hexagon shape
class PathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    
    // Hexagon shape calculations
    final r = math.min(width, height) * 0.4;
    final cx = width / 2;
    final cy = height / 2;
    
    // 6 points of hexagon
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

// Widget SVG icon helper
class SVGIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  
  const SVGIcon(this.icon, {required this.size, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}