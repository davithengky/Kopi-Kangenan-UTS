import 'package:flutter/material.dart';

import '../../providers/settings_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Pengaturan notifikasi (PRD F50).
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsStore.notifPromo,
      builder: (context, promo, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: SettingsStore.notifPesanan,
          builder: (context, pesanan, _) {
            return AppPage(
              title: 'Pengaturan Notifikasi',
              children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: promo,
                        activeThumbColor: AppColors.maroon,
                        onChanged: (value) =>
                            SettingsStore.setNotifPromo(value),
                        title: const Text(
                          'Promo & Voucher',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Info promo, voucher baru, dan cashback.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SwitchListTile(
                        value: pesanan,
                        activeThumbColor: AppColors.maroon,
                        onChanged: (value) =>
                            SettingsStore.setNotifPesanan(value),
                        title: const Text(
                          'Status Pesanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Pesanan sedang dibuat, siap diambil, dan selesai.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Notifikasi ini hanya simulasi di dalam aplikasi. Tidak ada '
                  'push notification sungguhan karena proyek ini belum memakai '
                  'server.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
