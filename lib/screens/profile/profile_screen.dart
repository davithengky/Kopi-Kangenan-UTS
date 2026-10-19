import 'package:flutter/material.dart';

import '../../models/inbox.dart';
import '../../providers/auth_store.dart';
import '../../providers/inbox_store.dart';
import '../../providers/member_store.dart';
import '../../providers/settings_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kangenan_coin.dart';
import '../../widgets/ui.dart';
import '../auth/auth_sheet.dart';
import '../checkout/payment_methods_screen.dart';
import '../merch/scan_merch_screen.dart';
import '../order/order_history_screen.dart';
import 'address_screen.dart';
import 'bulk_order_screen.dart';
import 'checkin_screen.dart';
import 'data_diri_screen.dart';
import 'inbox_screen.dart';
import 'language_screen.dart';
import 'points_history_screen.dart';
import 'static_page_screen.dart';

/// Halaman Profil (PRD F3–F5, F14, F43–F45, F49–F50).
///
/// Tata letaknya mengikuti `docs/design.md` §11.9. Yang berubah: kartu level
/// dan poin sekarang berisi data nyata, Daily Check-In bisa dipakai, dan semua
/// item menu membuka halamannya masing-masing (sebelumnya `onTap: () {}`).
///
/// Revisi terakhir menyesuaikan header dengan apps aslinya: avatar memakai
/// `assets/logo.png`, tombol kanan atas menjadi "Edit Profil" saat sudah masuk,
/// sapaan + level + poin digabung jadi satu kartu tiga kolom, dan tombol
/// "Keluar" dipindah ke section "Akun".
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Keluar dari akun dan kembali ke keadaan tamu.
  void _keluar(BuildContext context) {
    AuthStore.logout();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Anda telah keluar.')));
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  void _buka(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _section(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title, {
    Color iconColor = Colors.black54,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: AppColors.goldProfile),
        dense: true,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceProfile,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER PROFIL
                  //
                  // Sengaja memakai alur `Column` biasa, bukan tinggi tetap +
                  // `Positioned` seperti dulu. Sebelumnya header dipatok
                  // `SizedBox(height: 220)` dengan kartu di `top: 100`, jadi
                  // kartu berakhir tepat di batas 220 px dan kartu promo di
                  // bawahnya (margin atas 0) ikut menempel tanpa jarak. Dengan
                  // alur biasa, tinggi header selalu mengikuti isi kartunya dan
                  // jarak ke kartu promo tidak bisa hilang.
                  SizedBox(
                    height: 90,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // BAND ABU-ABU
                        Positioned.fill(
                          child: Container(color: AppColors.surfaceBand),
                        ),

                        // AVATAR: logo Kopi Kangenan, ring emas.
                        Positioned(
                          top: 8,
                          left: 20,
                          child: Container(
                            width: 74,
                            height: 74,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldProfile,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.local_cafe,
                                      color: AppColors.green,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        // AKSI KANAN ATAS (selalu di tengah tinggi band)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ValueListenableBuilder<AuthUser?>(
                                valueListenable: AuthStore.currentUser,
                                builder: (context, user, _) => user == null
                                    // Belum masuk → buka panel Login.
                                    ? ElevatedButton(
                                        onPressed: () => showAuthSheet(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        child: const Text('Masuk'),
                                      )
                                    // Sudah masuk → buka halaman Data Diri.
                                    // Tombol "Keluar" ada di section "Akun".
                                    : TextButton.icon(
                                        onPressed: () => _buka(
                                          context,
                                          const DataDiriScreen(),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 17,
                                        ),
                                        label: const Text(
                                          'Edit Profil',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // KARTU SAPAAN + LEVEL + POIN (satu kartu, tiga kolom)
                  GestureDetector(
                    onTap: () => _buka(context, const PointsHistoryScreen()),
                    child: Container(
                      key: const ValueKey('profil-kartu-level'),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: _cardDecoration(),
                      child: Row(
                        children: [
                          // 1. SAPAAN
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder<AuthUser?>(
                              valueListenable: AuthStore.currentUser,
                              builder: (context, user, _) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hai,',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Nama dibatasi + elipsis supaya nama
                                  // panjang tidak menabrak kolom sebelahnya.
                                  Text(
                                    user?.name ?? 'Guest',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: AppColors.surfaceTrack,
                          ),

                          // 2. LEVEL
                          Expanded(
                            flex: 4,
                            child: ValueListenableBuilder<int>(
                              valueListenable: MemberStore.totalSpent,
                              builder: (context, spent, _) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Level',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      // Progres bulat: lingkarannya sendiri
                                      // menjadi penanda persen.
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          value: MemberStore.levelProgress,
                                          strokeWidth: 2.5,
                                          color: AppColors.goldProfile,
                                          backgroundColor:
                                              AppColors.surfaceTrack,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          MemberStore.level.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(MemberStore.levelProgress * 100).round()}%',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: AppColors.surfaceTrack,
                          ),

                          // 3. POIN
                          Expanded(
                            flex: 4,
                            child: ValueListenableBuilder<int>(
                              valueListenable: MemberStore.points,
                              builder: (context, points, _) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kangenan Points',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const KangenanCoin(size: 15),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          '$points pts',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PROMO SPESIAL
                  //
                  // Jarak atas 16 px ke kartu level/poin dipasang lewat
                  // `Padding` (bukan `margin`) supaya batas kartunya terukur
                  // persis oleh tes tata letak.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Container(
                      key: const ValueKey('profil-kartu-promo'),
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '✨ Promo Spesial Buat Kamu!',
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Ikuti channel kami dan jangan lewatkan '
                                      'penawaran menarik setiap saat.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // GAMBAR PROMO
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 140,
                                  child: Image.asset(
                                    'assets/images.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.local_cafe,
                                        size: 70,
                                        color: AppColors.green,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () => showAppMessage(
                                context,
                                'Mengikuti WhatsApp Channel Kopi Kangenan… '
                                '(simulasi).',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.greenWhatsapp,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              // Material Icons tidak punya glyph WhatsApp dan
                              // proyek ini tidak menambah package, jadi ikonnya
                              // memakai `Icons.chat` seperti sebelumnya.
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text(
                                'Ikuti Sekarang',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // DAILY CHECK-IN
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.all(15),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Expanded supaya judul bisa menyusut dan tidak
                            // mendorong tombol "Detail" keluar layar.
                            const Expanded(
                              child: Text(
                                'Daily Check-In',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _buka(context, const CheckInScreen()),
                              child: const Text('Detail'),
                            ),
                          ],
                        ),
                        const Text(
                          'Berakhir 31 Okt 2026',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 112,
                          child: ValueListenableBuilder<Set<int>>(
                            valueListenable: MemberStore.checkedDays,
                            builder: (context, checkedDays, _) {
                              final nextDay = checkedDays.length + 1;

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: MemberStore.maxCheckInDays,
                                itemBuilder: (context, index) {
                                  final day = index + 1;
                                  final checked = checkedDays.contains(day);
                                  final voucher = MemberStore
                                      .dailyRewards[index]
                                      .contains('Voucher');
                                  final isNext = day == nextDay;

                                  return GestureDetector(
                                    onTap: () =>
                                        _buka(context, const CheckInScreen()),
                                    child: Container(
                                      width: 78,
                                      margin: const EdgeInsets.only(right: 7),
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: checked || isNext
                                              ? AppColors.goldProfile
                                              : Colors.grey.shade300,
                                          width: checked || isNext ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          // Koin "K" untuk hari biasa, centang
                                          // untuk yang selesai, dan ikon
                                          // voucher untuk hadiah voucher.
                                          checked || voucher
                                              ? Icon(
                                                  checked
                                                      ? Icons.check_circle
                                                      : Icons
                                                            .confirmation_num_outlined,
                                                  color: isNext
                                                      ? AppColors.goldProfile
                                                      : Colors.grey.shade400,
                                                  size: 24,
                                                )
                                              : KangenanCoin(
                                                  size: 24,
                                                  color: isNext
                                                      ? AppColors.goldCoin
                                                      : Colors.grey.shade400,
                                                ),
                                          Text(
                                            voucher ? 'Voucher' : '+25',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            checked
                                                ? 'Selesai'
                                                : 'Hari ke-$day',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AKUN
                  _section('Akun', [
                    _item(
                      Icons.person_outline,
                      'Data Diri',
                      onTap: () => _buka(context, const DataDiriScreen()),
                    ),
                    _item(
                      Icons.location_on_outlined,
                      'Alamat Pengiriman',
                      onTap: () => _buka(context, const AddressScreen()),
                    ),
                    _item(
                      Icons.shopping_bag_outlined,
                      'Scan Merchandise',
                      onTap: () => _buka(context, const ScanMerchScreen()),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: SettingsStore.biometric,
                      builder: (context, biometric, _) => _item(
                        Icons.fingerprint,
                        'Aktifkan Biometric ID',
                        trailing: Switch(
                          value: biometric,
                          activeThumbColor: AppColors.green,
                          onChanged: (value) {
                            SettingsStore.setBiometric(value);
                            showAppMessage(
                              context,
                              value
                                  ? 'Biometric ID diaktifkan (simulasi).'
                                  : 'Biometric ID dimatikan.',
                            );
                          },
                        ),
                        onTap: () {
                          SettingsStore.setBiometric(!biometric);
                          showAppMessage(
                            context,
                            !biometric
                                ? 'Biometric ID diaktifkan (simulasi).'
                                : 'Biometric ID dimatikan.',
                          );
                        },
                      ),
                    ),
                    _item(
                      Icons.language,
                      'Ubah Bahasa Aplikasi',
                      onTap: () => _buka(context, const LanguageScreen()),
                    ),
                    // Tombol "Keluar" hanya muncul saat sudah masuk. Dulu
                    // tombol ini ada di header, sekarang dipindah ke sini
                    // karena header dipakai untuk "Edit Profil".
                    ValueListenableBuilder<AuthUser?>(
                      valueListenable: AuthStore.currentUser,
                      builder: (context, user, _) => user == null
                          ? const SizedBox.shrink()
                          : _item(
                              Icons.logout,
                              'Keluar',
                              iconColor: AppColors.red,
                              onTap: () => _keluar(context),
                            ),
                    ),
                  ]),

                  // PESAN
                  _section('Pesan', [
                    ValueListenableBuilder<List<InboxMessage>>(
                      valueListenable: InboxStore.messages,
                      builder: (context, messages, _) {
                        final unread = InboxStore.unreadCount;

                        return _item(
                          Icons.inbox_outlined,
                          'Kotak Masuk',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (unread > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.goldProfile,
                              ),
                            ],
                          ),
                          onTap: () => _buka(context, const InboxScreen()),
                        );
                      },
                    ),
                    _item(
                      Icons.receipt_long_outlined,
                      'Riwayat Pesanan',
                      onTap: () => _buka(context, const OrderHistoryScreen()),
                    ),
                    _item(
                      Icons.account_balance_wallet_outlined,
                      'Metode Pembayaran',
                      onTap: () => _buka(context, const PaymentMethodsScreen()),
                    ),
                    _item(
                      Icons.shopping_basket_outlined,
                      'Pesanan Jumlah Besar',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.goldProfile,
                          ),
                        ],
                      ),
                      onTap: () => _buka(context, const BulkOrderScreen()),
                    ),
                  ]),

                  // Kopi Kangenan
                  _section('Kopi Kangenan', [
                    _item(
                      Icons.help_outline,
                      'Bantuan',
                      onTap: () => _buka(context, const HelpScreen()),
                    ),
                    _item(
                      Icons.menu_book_outlined,
                      'Kebijakan Privasi',
                      onTap: () => _buka(context, const PrivacyPolicyScreen()),
                    ),
                    _item(
                      Icons.info_outline,
                      'Ketentuan Layanan',
                      onTap: () => _buka(context, const TermsScreen()),
                    ),
                    _item(
                      Icons.mail_outline,
                      'Lapor Masalah',
                      onTap: () => _buka(context, const ReportProblemScreen()),
                    ),
                    _item(
                      Icons.support_agent,
                      'Layanan WhatsApp',
                      onTap: () =>
                          _buka(context, const WhatsappServiceScreen()),
                    ),
                    _item(
                      Icons.favorite_border,
                      'Tentang Kopi Kangenan',
                      iconColor: AppColors.red,
                      onTap: () => _buka(context, const AboutScreen()),
                    ),
                  ]),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 24, top: 2),
                    child: Center(
                      child: Text(
                        'Kopi Kangenan • Versi 1.0.0',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
