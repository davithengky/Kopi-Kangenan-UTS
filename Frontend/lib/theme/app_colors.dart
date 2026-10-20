import 'package:flutter/material.dart';

/// Token warna aplikasi.
///
/// Nilainya diambil apa adanya dari `docs/design.md` §3. **Tidak ada** warna
/// baru yang dikarang di sini: setiap token sudah dipakai di salah satu layar
/// dan nilainya dipertahankan persis, hanya namanya yang distandarkan
/// (`docs/design.md` §16.2).
///
/// Layar baru **wajib** mengambil warna dari sini, bukan menulis
/// `Color(0x…)` sendiri (§14.1, §15).
class AppColors {
  const AppColors._();

  // --- Brand -------------------------------------------------------------
  /// `0xFF7A263D` — warna identitas utama (ikon nav aktif, judul, tab aktif).
  static const maroon = Color(0xFF7A263D);

  /// `0xFFB51F2D` — tombol aksi: `+ Keranjang`, `Klaim`, `Buy Pack`.
  static const action = Color(0xFFB51F2D);

  /// `0xFFF8DDE1` — latar pill harga produk (§10.21).
  static const pink = Color(0xFFF8DDE1);

  // --- Aksen -------------------------------------------------------------
  /// `0xFFB99565` — border opsi terpilih, garis bawah tab Menu, ikon aksi.
  static const gold = Color(0xFFB99565);

  /// `0xFF218B55` — badge promo, tombol Masuk, badge `New`.
  static const green = Color(0xFF218B55);

  /// `0xFF54A77D` — bulatan ikon "Diskon & Cashback" (§10.24).
  static const greenIcon = Color(0xFF54A77D);

  /// `0xFFB3262D` — teks pill harga, ikon hapus, ikon "Tentang Kopi Kangenan".
  static const red = Color(0xFFB3262D);

  // --- Teks --------------------------------------------------------------
  /// `0xFF171717` — judul utama.
  static const textPrimary = Color(0xFF171717);

  /// `0xFF777777` — **teks sekunder standar** (§3.7).
  static const textSecondary = Color(0xFF777777);

  // --- Garis & permukaan -------------------------------------------------
  /// `0xFFEDEDED` — border kartu checkout & kartu metode pembayaran.
  static const border = Color(0xFFEDEDED);

  /// `0xFFE5E5E5` — garis atas bottom bar, border kotak jumlah, tombol "Klaim".
  static const borderSoft = Color(0xFFE5E5E5);

  /// `0xFFD9D9D9` — border tombol "Lanjutkan dengan Google".
  static const outline = Color(0xFFD9D9D9);

  /// `0xFFF4F4F4` — latar field input panel Login/Daftar.
  static const fieldFill = Color(0xFFF4F4F4);

  // ==== Tambahan: dipindahkan dari layar lama, nilai tidak diubah ==========

  // --- Merah semantik per layar (§3.2) -----------------------------------
  /// `0xFFB92429` — tombol Bayar & aksen Checkout.
  static const checkoutRed = Color(0xFFB92429);

  /// `0xFFB82025` — total, countdown, ikon, reminder QRIS.
  static const qrisRed = Color(0xFFB82025);

  // --- Emas per layar (§3.3) --------------------------------------------
  /// `0xFFC6A577` — border kartu pembayaran terpilih, harga menu.
  static const goldBorder = Color(0xFFC6A577);

  /// `0xFFD9B54A` — progress bar & chevron Profil.
  static const goldProfile = Color(0xFFD9B54A);

  /// `0xFFC69A69` — dot indikator kartu membership VIP.
  static const goldVipDot = Color(0xFFC69A69);

  /// `0xFFB89B65` — ikon kartu benefit VIP.
  static const goldVipIcon = Color(0xFFB89B65);

  /// `0xFFB69A78` — judul "Custom Merchandise" + divider Merch.
  static const goldMerch = Color(0xFFB69A78);

  /// `0xFFD2A36D` — ikon hadiah di kartu voucher Beranda.
  static const goldGift = Color(0xFFD2A36D);

  /// `0xFFA6783A` — subjudul metode pembayaran di Checkout.
  static const goldSubtitle = Color(0xFFA6783A);

  /// `0xFFBE9B6D` — border tombol bawah QRIS.
  static const goldQris = Color(0xFFBE9B6D);

  /// `0xFFC4A047` — koin `KangenanCoin` (Profil, Daily Check-In) & lingkaran
  /// koin di kartu membership.
  static const goldCoin = Color(0xFFC4A047);

  /// `0xFFB98050` — border 2px kartu voucher Beranda.
  static const goldVoucherBorder = Color(0xFFB98050);

  // --- Hijau per layar (§3.4) -------------------------------------------
  /// `0xFF278F59` — badge "Save 98%", harga paket voucher VIP.
  static const greenVip = Color(0xFF278F59);

  /// `0xFF20C96B` — lingkaran WhatsApp & tombol "Ikuti Sekarang".
  static const greenWhatsapp = Color(0xFF20C96B);

  /// `0xFF75B879` — dot "Delivery".
  static const greenDelivery = Color(0xFF75B879);

  /// `0xFF64BDB6` — dot "Pickup".
  static const greenPickup = Color(0xFF64BDB6);

  /// `0xFF319795` — ikon storefront (latar `greenStoreBg`).
  static const greenStorefront = Color(0xFF319795);

  /// `0xFF38B2AC` — ikon outlet terpilih (mint).
  static const mint = Color(0xFF38B2AC);

  /// `0xFFEAF6EF` — latar badge "Gratis Ukir".
  static const greenBadgeBg = Color(0xFFEAF6EF);

  /// `0xFF65A486` — teks badge "Gratis Ukir".
  static const greenBadgeText = Color(0xFF65A486);

  /// `0xFFEBF6F6` — kotak ikon storefront.
  static const greenStoreBg = Color(0xFFEBF6F6);

  // --- Biru (§3.5) -------------------------------------------------------
  /// `0xFF00A3C8` — brand blu by BCA Digital.
  static const blueBlu = Color(0xFF00A3C8);

  /// `0xFF00AED6` — brand GoPay.
  static const blueGopay = Color(0xFF00AED6);

  /// `0xFF3B82F6` — teks link "Lihat Semua".
  static const blueLink = Color(0xFF3B82F6);

  /// `0xFFE0E7EE` — latar container tab VIP & toggle mode.
  static const blueGreyTab = Color(0xFFE0E7EE);

  /// `0xFFE4E5E8` — border tab aktif VIP.
  static const blueTabBorder = Color(0xFFE4E5E8);

  // --- Warning (§3.6) ----------------------------------------------------
  /// `0xFFF59E0B` — ikon warning / status Pending.
  static const warning = Color(0xFFF59E0B);

  /// `0xFFFFF8E7` — latar kotak peringatan.
  static const warningBg = Color(0xFFFFF8E7);

  // --- Teks netral tambahan (§3.7) ---------------------------------------
  /// `0xFF252525` — teks utama QRIS.
  static const textQris = Color(0xFF252525);

  /// `0xFF303030` — teks utama VIP.
  static const textVip = Color(0xFF303030);

  /// `0xFF38332B` — teks kotak countdown QRIS.
  static const textCountdown = Color(0xFF38332B);

  /// `0xFF555555` — judul header VIP.
  static const textVipHeader = Color(0xFF555555);

  /// `0xFF55565B` — teks kartu membership.
  static const textMembership = Color(0xFF55565B);

  /// `0xFF858585` — teks sekunder khusus VIP.
  static const textVipGrey = Color(0xFF858585);

  /// `0xFFB8C0BD` — harga asli (dicoret).
  static const textStrike = Color(0xFFB8C0BD);

  /// `0xFF66666B` — angka "0" di kartu membership.
  static const textZero = Color(0xFF66666B);

  /// `0xFF88888D` — "/699.999" di kartu membership.
  static const textTarget = Color(0xFF88888D);

  /// `0xFF9E9E9E` — keterangan kustomisasi di kartu pesanan.
  static const textMuted = Color(0xFF9E9E9E);

  // --- Permukaan (§3.8) --------------------------------------------------
  /// `0xFFFBFBFB` — latar Checkout.
  static const surfaceCheckout = Color(0xFFFBFBFB);

  /// `0xFFF8F9FA` — latar QRIS.
  static const surfaceQris = Color(0xFFF8F9FA);

  /// `0xFFF7F7F7` — latar Profil.
  static const surfaceProfile = Color(0xFFF7F7F7);

  /// `0xFFF1F4F8` — latar VIP.
  static const surfaceVip = Color(0xFFF1F4F8);

  /// `0xFFFAFAFA` — kotak opsi kustomisasi, kotak instruksi QRIS.
  static const surfaceOption = Color(0xFFFAFAFA);

  /// `0xFFF8F8F8` — border opsi tidak terpilih.
  static const surfaceOptionBorder = Color(0xFFF8F8F8);

  /// `0xFFF5F5F5` — kotak jumlah voucher Checkout.
  static const surfaceMuted = Color(0xFFF5F5F5);

  /// `0xFFF2F2F2` — kotak jumlah voucher VIP.
  static const surfaceMuted2 = Color(0xFFF2F2F2);

  /// `0xFFF0F0F0` — band header Profil.
  static const surfaceBand = Color(0xFFF0F0F0);

  /// `0xFFEAEAEA` — latar progress bar membership.
  static const surfaceTrack = Color(0xFFEAEAEA);

  /// `0xFFE8E8E8` — latar `MobileFrame`.
  static const surfaceFrame = Color(0xFFE8E8E8);

  /// `0xFFE0E0E0` — latar baris "Out of Stock".
  static const surfaceDisabled = Color(0xFFE0E0E0);

  /// `0xFFF8EFE4` — kotak countdown QRIS saat aktif.
  static const countdownActiveBg = Color(0xFFF8EFE4);

  /// `0xFFFFE8E8` — kotak countdown QRIS saat habis.
  static const countdownExpiredBg = Color(0xFFFFE8E8);

  /// `0xFFEEEEEE` — border kotak instruksi QRIS.
  static const instructionBorder = Color(0xFFEEEEEE);

  /// `0xFFE7E7E7` — border kartu QRIS.
  static const qrBorder = Color(0xFFE7E7E7);

  /// `0xFFC4C4C4` — dot indikator non-aktif.
  static const dotInactive = Color(0xFFC4C4C4);

  /// `0xFFBDBDBD` — ikon/teks non-aktif.
  static const disabled = Color(0xFFBDBDBD);

  // --- Kartu membership Silver (§10.8) ----------------------------------
  /// `0xFFF9FBFF` — awal gradient kartu membership.
  static const silverStart = Color(0xFFF9FBFF);

  /// `0xFFD5DDE7` — akhir gradient kartu membership.
  static const silverEnd = Color(0xFFD5DDE7);

  /// `0xFFADB4BE` — border kartu membership.
  static const silverBorder = Color(0xFFADB4BE);

  /// `0xFFE1E1E6` — lingkaran tombol VIP di bottom navigation (§10.2).
  static const navVipCircle = Color(0xFFE1E1E6);

  // --- Warna layar lama yang belum punya token ---------------------------
  // Nilainya dipakai apa adanya oleh layar yang sudah ada; ditambahkan ke sini
  // supaya file baru tidak perlu menulis `Color(0x…)` sendiri (§14.1).

  /// `0xFFFFC844` — ikon koin di header Beranda.
  static const coinYellow = Color(0xFFFFC844);

  /// `0xFFFFE3E5` — latar menu pintas "Order" di Beranda.
  static const quickRed = Color(0xFFFFE3E5);

  /// `0xFFFFE8C8` — latar menu pintas "Delivery Hemat".
  static const quickOrange = Color(0xFFFFE8C8);

  /// `0xFFFFE1D5` — latar menu pintas "Chicken & Burger".
  static const quickPeach = Color(0xFFFFE1D5);

  /// `0xFFE4F0D9` — latar menu pintas "Catering & Wedding".
  static const quickGreen = Color(0xFFE4F0D9);

  /// `0xFFC6C6C6` — garis putus-putus kartu voucher VIP.
  static const dashedLine = Color(0xFFC6C6C6);

  /// `0x18000000` — bayangan tipis kartu voucher VIP.
  static const shadowSoft = Color(0x18000000);

  /// `0xFFDDDDDD` — border kartu benefit VIP.
  static const borderBenefit = Color(0xFFDDDDDD);

  /// `0xFFF8F3EB` — latar `Scaffold` utama aplikasi (`main.dart`).
  static const scaffoldBackground = Color(0xFFF8F3EB);
}
