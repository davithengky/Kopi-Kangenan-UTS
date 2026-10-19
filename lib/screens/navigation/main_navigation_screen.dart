import 'package:flutter/material.dart';

import '../../providers/settings_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/strings.dart';
import '../home/home_screen.dart';
import '../menu/menu_screen.dart';
import '../vip/vip_screen.dart';
import '../merch/merch_screen.dart';
import '../profile/profile_screen.dart';

/// Shell utama aplikasi: menampung 5 tab beserta bottom navigation.
///
/// Setiap tab punya area scroll-nya sendiri. Sebelumnya Beranda dan Menu
/// digabung dalam satu `SingleChildScrollView` sehingga tab berpindah sendiri
/// saat pengguna men-scroll; sekarang keduanya sudah halaman terpisah.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  void _select(int index) {
    setState(() => selectedIndex = index);
  }

  Widget _page() {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: HomeScreen(onSelectTab: _select),
            ),
          ),
        );
      case 1:
        return const MenuScreen();
      case 2:
        return const VipScreen();
      case 3:
        return const MerchScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _page()),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: ValueListenableBuilder<AppLanguage>(
                    valueListenable: SettingsStore.language,
                    builder: (context, language, _) => Row(
                      children: [
                        _navItem(
                          icon: Icons.home_outlined,
                          label: Strings.beranda(language),
                          index: 0,
                        ),
                        _navItem(
                          icon: Icons.favorite_border,
                          label: Strings.menu(language),
                          index: 1,
                        ),

                        // Tombol VIP di tengah
                        Expanded(
                          child: InkWell(
                            onTap: () => _select(2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, -8),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.navVipCircle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      selectedIndex == 2
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: selectedIndex == 2
                                          ? AppColors.maroon
                                          : Colors.grey.shade600,
                                      size: 27,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -6),
                                  child: Text(
                                    Strings.vip(language),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: selectedIndex == 2
                                          ? AppColors.maroon
                                          : Colors.grey,
                                      fontWeight: selectedIndex == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        _navItem(
                          icon: Icons.local_drink_outlined,
                          label: Strings.merch(language),
                          index: 3,
                        ),
                        _navItem(
                          icon: Icons.person_outline,
                          label: Strings.saya(language),
                          index: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final active = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _select(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: active ? AppColors.maroon : Colors.grey),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.maroon : Colors.grey,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
