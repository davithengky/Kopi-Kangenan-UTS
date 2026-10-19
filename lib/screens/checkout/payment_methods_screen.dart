import 'package:flutter/material.dart';

import '../../models/payment_method.dart';
import '../../providers/payment_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Daftar seluruh metode pembayaran (PRD F34).
///
/// Dipakai dua cara:
/// - [selectMode] `true` → dibuka dari Checkout lewat tautan "Lihat Semua",
///   mengetuk satu metode akan memilihnya lalu menutup halaman.
/// - [selectMode] `false` → dibuka dari Profil sebagai halaman pengaturan.
class PaymentMethodsScreen extends StatelessWidget {
  final bool selectMode;

  const PaymentMethodsScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: PaymentStore.connectedIds,
      builder: (context, connected, _) {
        return ValueListenableBuilder<String>(
          valueListenable: PaymentStore.selectedId,
          builder: (context, selectedId, _) {
            return AppPage(
              title: selectMode ? 'Pilih Pembayaran' : 'Metode Pembayaran',
              children: [
                if (selectMode)
                  const Text(
                    'Metode yang butuh koneksi harus dihubungkan dulu sebelum '
                    'bisa dipakai.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 12),
                for (final method in kPaymentMethods) ...[
                  _methodTile(
                    context,
                    method,
                    connected: PaymentStore.isConnected(method),
                    selected: selectedId == method.id,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _methodTile(
    BuildContext context,
    PaymentMethod method, {
    required bool connected,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        if (!connected) {
          showAppMessage(
            context,
            'Hubungkan ${method.name} dulu untuk memakainya.',
          );
          return;
        }

        PaymentStore.select(method);

        if (selectMode) {
          showAppMessage(context, 'Pembayaran ${method.name} dipilih.');
          Navigator.maybePop(context);
        } else {
          showAppMessage(context, 'Metode utama: ${method.name}.');
        }
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: method.brandColor ?? Colors.white,
                shape: BoxShape.circle,
                border: method.brandColor == null
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Icon(
                method.icon,
                size: 22,
                color: method.brandColor == null
                    ? Colors.black87
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!connected)
              TextButton(
                onPressed: () {
                  PaymentStore.connect(method.id);
                  showAppMessage(context, '${method.name} berhasil dihubungkan.');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blueLink,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Hubungkan'),
              )
            else if (selected)
              const Icon(Icons.check_circle, color: AppColors.maroon, size: 22)
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.borderSoft,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
