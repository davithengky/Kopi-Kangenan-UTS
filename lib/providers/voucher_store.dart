import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/voucher.dart';
import '../services/sync_service.dart';

/// Kesalahan yang muncul saat kode voucher tidak bisa dipakai.
class VoucherException implements Exception {
  const VoucherException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Voucher milik pembeli, promo yang sudah diklaim, dan paket yang dibeli
/// (PRD F10, F32, F33, F40, F41). Semua hanya di memori.
class VoucherStore {
  VoucherStore._();

  static final ValueNotifier<List<Voucher>> userVouchers =
      ValueNotifier<List<Voucher>>(<Voucher>[]);

  /// Label promo yang sudah diklaim dari section "Diskon & Cashback".
  static final ValueNotifier<List<String>> claimedPromos =
      ValueNotifier<List<String>>(<String>[]);

  static final ValueNotifier<List<VoucherPack>> ownedPacks =
      ValueNotifier<List<VoucherPack>>(<VoucherPack>[]);

  /// Kode contoh yang selalu bisa dipakai, supaya alur "Pakai Kode Voucher"
  /// bisa dicoba tanpa membeli paket lebih dulu.
  static const Voucher demoVoucher = Voucher(
    code: 'KANGENAN10',
    title: 'Voucher Diskon 10%',
    description: 'Diskon 10% untuk semua minuman, min. belanja Rp30.000.',
    minPurchase: 30000,
    percent: 10,
  );

  static const List<Voucher> catalog = [
    demoVoucher,
    Voucher(
      code: 'GRATISKOPI',
      title: 'Voucher Gratis 1 Minuman',
      description: 'Potongan Rp25.000 tanpa minimum pembelian.',
      amount: 25000,
      kind: VoucherKind.gratis,
    ),
    Voucher(
      code: 'ONGKIRHEMAT',
      title: 'Voucher Delivery Rp5.000',
      description: 'Potongan Rp5.000 untuk pesanan Delivery.',
      minPurchase: 50000,
      amount: 5000,
      kind: VoucherKind.delivery,
    ),
  ];

  static bool get hasClaimedBuyOneGetOne =>
      claimedPromos.value.contains('Buy 1 Get 1');

  static void claimPromo(String label) {
    if (claimedPromos.value.contains(label)) return;

    claimedPromos.value = [...claimedPromos.value, label];

    unawaited(SyncService.pushPromoClaim(label));
  }

  /// Membeli paket voucher. Vouchernya langsung masuk ke akun.
  static void buyPack(VoucherPack pack) {
    ownedPacks.value = [...ownedPacks.value, pack];
    userVouchers.value = [...userVouchers.value, ...vouchersFromPack(pack)];

    unawaited(SyncService.pushBuyVoucherPack(pack.id));
  }

  /// Mencari voucher dari kode yang diketik pembeli.
  ///
  /// Mencari dulu di voucher milik pembeli, lalu di katalog contoh. Melempar
  /// [VoucherException] kalau kodenya tidak dikenal.
  static Voucher validateCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw const VoucherException('Masukkan kode voucher dulu.');
    }

    for (final voucher in userVouchers.value) {
      if (voucher.code.toUpperCase() == code) return voucher;
    }

    for (final voucher in catalog) {
      if (voucher.code.toUpperCase() == code) {
        userVouchers.value = [...userVouchers.value, voucher];
        unawaited(SyncService.pushVoucherCode(voucher.code));
        return voucher;
      }
    }

    throw const VoucherException('Kode voucher tidak dikenal atau sudah kadaluarsa.');
  }

  static void reset() {
    userVouchers.value = <Voucher>[];
    claimedPromos.value = <String>[];
    ownedPacks.value = <VoucherPack>[];
  }
}
