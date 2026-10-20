import 'package:flutter/material.dart';

import '../../models/voucher.dart';
import '../../providers/voucher_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';

/// Halaman "Beli Paket Voucher" (PRD F33/F41).
///
/// Dipakai dari Checkout maupun dari tab Voucher Pack di halaman VIP, jadi
/// keduanya tidak mungkin berbeda isi.
class VoucherPackScreen extends StatelessWidget {
  const VoucherPackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<VoucherPack>>(
      valueListenable: VoucherStore.ownedPacks,
      builder: (context, owned, _) {
        return AppPage(
          title: 'Paket Voucher',
          children: [
            const Text(
              'Beli paket voucher sekali, hemat berkali-kali. Voucher langsung '
              'masuk ke akunmu dan bisa dipakai saat checkout.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (final pack in kVoucherPacks) ...[
              _packCard(context, pack, owned.contains(pack)),
              const SizedBox(height: 14),
            ],
            if (owned.isNotEmpty) ...[
              const SizedBox(height: 6),
              const AppSectionLabel(text: 'Paketmu'),
              for (final pack in owned)
                AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pack.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _packCard(BuildContext context, VoucherPack pack, bool owned) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pack.description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 58,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pack.count,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 26,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      formatRupiah(pack.oldPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textStrike,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pack.saving,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(pack.price),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: owned ? 'Beli Lagi' : 'Buy Pack',
            onPressed: () {
              VoucherStore.buyPack(pack);
              showAppMessage(
                context,
                '${pack.title} berhasil dibeli. Voucher masuk ke akunmu!',
              );
            },
          ),
        ],
      ),
    );
  }
}
