import 'package:flutter/material.dart';

import '../../models/voucher.dart';
import '../../providers/auth_store.dart';
import '../../providers/member_store.dart';
import '../../providers/voucher_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  int selectedTab = 1;
  int selectedLevel = 0;

  /// Filter jenis voucher di tab Voucher. `null` berarti "Semua".
  VoucherKind? selectedKind;

  final TextEditingController _kodeController = TextEditingController();

  final List<String> tabs = ['Voucher', 'Voucher Pack', 'Benefits'];

  @override
  void dispose() {
    _kodeController.dispose();
    super.dispose();
  }

  /// Menukar kode voucher jadi voucher di akun (PRD F32).
  void _pakaiKode() {
    try {
      final voucher = VoucherStore.validateCode(_kodeController.text);
      _kodeController.clear();
      showAppMessage(context, 'Voucher ${voucher.title} masuk ke akunmu.');
    } on VoucherException catch (error) {
      showAppMessage(context, error.message);
    }
  }

  /// Menampilkan kode voucher supaya bisa dipakai di halaman Checkout.
  void _tampilkanKode(BuildContext context, Voucher voucher) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              voucher.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              voucher.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                voucher.code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Masukkan kode ini di halaman Checkout → "Pakai Kode Voucher".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'Tutup',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _voucherPrice(Voucher voucher) {
    if (voucher.percent > 0) return '-${voucher.percent}%';
    if (voucher.amount > 0) return '-${formatRupiah(voucher.amount)}';
    return 'GRATIS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVip,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                // HEADER
                SizedBox(
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Kopi Kangenan VIP',
                        style: TextStyle(
                          color: AppColors.textVipHeader,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // KONTEN YANG BISA DI-SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: MemberStore.totalSpent,
                          builder: (context, spent, _) =>
                              ValueListenableBuilder<AuthUser?>(
                                valueListenable: AuthStore.currentUser,
                                builder: (context, user, _) =>
                                    _buildSilverCard(),
                              ),
                        ),

                        const SizedBox(height: 14),

                        // INDIKATOR KARTU
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedLevel = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: selectedLevel == index ? 30 : 8,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: selectedLevel == index
                                      ? AppColors.goldVipDot
                                      : AppColors.dotInactive,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 18),

                        // PANEL VOUCHER
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTabs(),

                              const SizedBox(height: 22),

                              Text(
                                selectedTab == 2
                                    ? 'Benefits Member'
                                    : 'Tersedia',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textVip,
                                ),
                              ),

                              const SizedBox(height: 16),

                              if (selectedTab == 0) ...[
                                _buildVoucherTab(context),
                              ] else if (selectedTab == 1) ...[
                                _buildVoucherPackTab(context),
                              ] else ...[
                                _buildBenefitsTab(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TAB VOUCHER
  Widget _buildVoucherTab(BuildContext context) {
    return ValueListenableBuilder<List<Voucher>>(
      valueListenable: VoucherStore.userVouchers,
      builder: (context, vouchers, _) {
        final filtered = selectedKind == null
            ? vouchers
            : vouchers.where((voucher) => voucher.kind == selectedKind).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter jenis voucher
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _kindChip(
                    'Semua',
                    selectedKind == null,
                    () => setState(() => selectedKind = null),
                  ),
                  for (final kind in VoucherKind.values)
                    _kindChip(
                      kind.label,
                      selectedKind == kind,
                      () => setState(() => selectedKind = kind),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tukar kode voucher
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Punya kode voucher?',
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _pakaiKode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.action,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Pakai'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (vouchers.isEmpty)
              const Text(
                'Belum ada voucher. Klaim promo di Beranda atau beli paket '
                'voucher di tab Voucher Pack.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textVipGrey,
                ),
              )
            else if (filtered.isEmpty)
              Text(
                'Tidak ada voucher ${selectedKind?.label.toLowerCase()}.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textVipGrey,
                ),
              )
            else
              for (final voucher in filtered) ...[
                _buildVoucherCard(
                  title: voucher.title,
                  description: voucher.description,
                  oldPrice: '',
                  price: _voucherPrice(voucher),
                  saving: '',
                  count: '1x',
                  buttonLabel: 'Pakai',
                  onTap: () => _tampilkanKode(context, voucher),
                ),
                const SizedBox(height: 18),
              ],
          ],
        );
      },
    );
  }

  /// Chip filter jenis voucher.
  Widget _kindChip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.maroon : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.maroon : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : AppColors.textVipGrey,
            ),
          ),
        ),
      ),
    );
  }

  // TAB VOUCHER PACK
  Widget _buildVoucherPackTab(BuildContext context) {
    return ValueListenableBuilder<List<VoucherPack>>(
      valueListenable: VoucherStore.ownedPacks,
      builder: (context, owned, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final pack in kVoucherPacks) ...[
              _buildVoucherCard(
                title: pack.title,
                description: pack.description,
                oldPrice: formatRupiah(pack.oldPrice),
                price: formatRupiah(pack.price),
                saving: pack.saving,
                count: pack.count,
                buttonLabel: owned.contains(pack) ? 'Beli Lagi' : 'Buy Pack',
                onTap: () {
                  VoucherStore.buyPack(pack);
                  showAppMessage(
                    context,
                    '${pack.title} berhasil dibeli. Voucher masuk ke akunmu!',
                  );
                },
              ),
              const SizedBox(height: 18),
            ],
            Text(
              owned.isEmpty
                  ? 'Voucher dari paket bisa langsung dipakai di halaman '
                        'Checkout dengan kodenya.'
                  : 'Paketmu: ${owned.map((pack) => pack.title).join(', ')}',
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textVipGrey,
              ),
            ),
          ],
        );
      },
    );
  }

  // TAB BENEFITS
  Widget _buildBenefitsTab() {
    return ValueListenableBuilder<int>(
      valueListenable: MemberStore.totalSpent,
      builder: (context, spent, _) {
        final level = MemberStore.level;

        return Column(
          children: [
            _buildBenefitCard(
              Icons.workspace_premium,
              'Level kamu: ${level.label}',
              level.isHighest
                  ? 'Kamu sudah di level tertinggi dan mendapat semua benefit.'
                  : 'Belanja ${formatRupiah(MemberStore.remainingToNextLevel)} '
                        'lagi untuk naik ke Level ${level.next.label}.',
            ),
            const SizedBox(height: 12),
            _buildBenefitCard(
              Icons.favorite_outline,
              'Keuntungan Member',
              'Nikmati penawaran khusus untuk member Kangenan VIP.',
            ),
            const SizedBox(height: 12),
            _buildBenefitCard(
              Icons.local_cafe_outlined,
              'Promo Minuman',
              'Akses promo dan penawaran minuman pilihan.',
            ),
            const SizedBox(height: 12),
            _buildBenefitCard(
              Icons.card_giftcard,
              'Poin & Voucher',
              '1 Kangenan Point = Rp1 saat checkout. Poin didapat dari '
                  'pesanan dan Daily Check-In.',
            ),
          ],
        );
      },
    );
  }

  // KARTU SILVER RESPONSIF
  Widget _buildSilverCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardHeight = (width * 0.78).clamp(255.0, 330.0);
        final titleSize = (width * 0.085).clamp(25.0, 34.0);

        return Container(
          height: cardHeight,
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.055),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.silverStart, AppColors.silverEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.silverBorder, width: 2),
          ),
          child: Stack(
            children: [
              // Ilustrasi di sisi kanan kartu
              Positioned(
                right: -width * 0.02,
                top: cardHeight * 0.15,
                child: Icon(
                  Icons.workspace_premium,
                  size: width * 0.39,
                  color: Colors.grey.shade400.withValues(alpha: 0.8),
                ),
              ),
              Positioned(
                right: width * 0.09,
                top: cardHeight * 0.30,
                child: Icon(
                  Icons.favorite,
                  size: width * 0.17,
                  color: Colors.white,
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        MemberStore.level.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMembership,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textMembership,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${(MemberStore.levelProgress * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: cardHeight * 0.065),

                  Text(
                    'Hai, ${AuthStore.displayName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textVip,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: cardHeight * 0.09),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatAngka(MemberStore.totalSpent.value),
                          style: const TextStyle(
                            fontSize: 28,
                            color: AppColors.textZero,
                          ),
                        ),
                        TextSpan(
                          text: MemberStore.level.isHighest
                              ? ''
                              : ' / ${formatAngka(MemberStore.level.nextThreshold)}',
                          style: TextStyle(
                            fontSize: width * 0.048,
                            color: AppColors.textTarget,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 29,
                        height: 29,
                        decoration: const BoxDecoration(
                          color: AppColors.goldCoin,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: AppColors.textMembership,
                        fontSize: width * 0.037,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(text: 'Belanja '),
                        TextSpan(
                          text: MemberStore.level.isHighest
                              ? '0'
                              : formatRupiah(MemberStore.remainingToNextLevel),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: MemberStore.level.isHighest
                              ? ' lagi — kamu di level tertinggi!'
                              : ' lagi untuk naik ke Level '
                                    '${MemberStore.level.next.label}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB VOUCHER
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.blueGreyTab,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active
                        ? AppColors.blueTabBorder
                        : Colors.transparent,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tabs[index],
                    style: const TextStyle(
                      color: AppColors.textVip,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // KARTU VOUCHER RESPONSIF
  Widget _buildVoucherCard({
    required String title,
    required String description,
    required String oldPrice,
    required String price,
    required String saving,
    required String count,
    String buttonLabel = 'Buy Pack',
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashedLine, width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textVip,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textVipGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                        count,
                        style: const TextStyle(
                          color: AppColors.action,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 28,
                        color: AppColors.textVip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Garis putus-putus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(
                35,
                (index) => Expanded(
                  child: Container(
                    height: 1.2,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: index.isEven
                        ? AppColors.dashedLine
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (oldPrice.isNotEmpty)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          runSpacing: 3,
                          children: [
                            Text(
                              oldPrice,
                              style: const TextStyle(
                                color: AppColors.textStrike,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            if (saving.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.greenVip,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  saving,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.greenVip,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 43,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.action,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BENEFITS
  Widget _buildBenefitCard(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderBenefit),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppColors.goldVipIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textVipGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
