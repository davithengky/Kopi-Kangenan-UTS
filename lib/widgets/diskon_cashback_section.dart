import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Section "Diskon & Cashback" yang dipakai bersama oleh Beranda dan Menu.
///
/// Menampilkan daftar kartu promo yang bisa di-scroll horizontal. Setiap kartu
/// punya badge hijau di pojok kiri atas, nilai potongan, nama mitra, dan tombol
/// "Klaim".
class DiskonCashbackSection extends StatelessWidget {
  /// Beranda memakai inset 20, Menu memakai 16.
  final double horizontalPadding;

  final void Function(String label)? onKlaim;

  const DiskonCashbackSection({
    super.key,
    this.horizontalPadding = 16,
    this.onKlaim,
  });

  static const List<_PromoItem> _promos = [
    _PromoItem(label: 'Diskon', amount: '5.000', partner: 'OVO'),
    _PromoItem(label: 'Ongkir', amount: '5.000', partner: 'GExpress'),
  ];

  void _klaim(BuildContext context, String label) {
    if (onKlaim != null) {
      onKlaim!(label);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Promo $label berhasil diklaim!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.greenIcon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Diskon & Cashback',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: horizontalPadding),
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];

              return _PromoCard(
                promo: promo,
                onKlaim: () => _klaim(context, promo.label),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PromoItem {
  final String label;
  final String amount;
  final String partner;

  const _PromoItem({
    required this.label,
    required this.amount,
    required this.partner,
  });
}

class _PromoCard extends StatelessWidget {
  final _PromoItem promo;
  final VoidCallback onKlaim;

  const _PromoCard({required this.promo, required this.onKlaim});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge hijau menempel di sudut kiri atas kartu.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: const BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(
              promo.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                // mainAxisSize.min + tanpa Expanded pada kartu membuat tinggi
                // kartu mengikuti isi, sehingga teks tidak pernah terpotong
                // walau metrik font berbeda (mis. saat dijalankan di test).
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        promo.amount,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        promo.partner,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: onKlaim,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSoft),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Klaim'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
