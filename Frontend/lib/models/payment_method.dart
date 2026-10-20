import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Satu metode pembayaran yang bisa dipilih di Checkout (PRD F34).
class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color? brandColor;

  /// Butuh dihubungkan dulu (mis. GoPay) sebelum bisa dipakai.
  final bool needsConnection;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    this.brandColor,
    this.needsConnection = false,
  });
}

/// Semua metode pembayaran yang tersedia.
///
/// Hanya brand yang benar-benar dipakai aplikasi referensi (QRIS, blu by BCA
/// Digital, GoPay) plus satu opsi kartu netral. Warna brand diambil dari
/// `AppColors` supaya tidak ada nilai baru yang dikarang
/// (lihat `docs/design.md` §3.5).
const List<PaymentMethod> kPaymentMethods = [
  PaymentMethod(
    id: 'qris',
    name: 'QRIS',
    subtitle: 'Simpan QR dan bayar',
    icon: Icons.qr_code_2,
  ),
  PaymentMethod(
    id: 'blu',
    name: 'blu by BCA Digital',
    subtitle: 'Cashback 40% max. 25RB*',
    icon: Icons.account_balance_wallet,
    brandColor: AppColors.blueBlu,
  ),
  PaymentMethod(
    id: 'gopay',
    name: 'GoPay',
    subtitle: 'Hubungkan akun',
    icon: Icons.account_balance_wallet,
    brandColor: AppColors.blueGopay,
    needsConnection: true,
  ),
  PaymentMethod(
    id: 'kartu',
    name: 'Kartu Debit/Kredit',
    subtitle: 'Visa, Mastercard, JCB',
    icon: Icons.credit_card,
  ),
];
