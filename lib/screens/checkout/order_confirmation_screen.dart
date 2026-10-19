import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../models/order.dart';
import '../../models/outlet.dart';
import '../../models/voucher.dart';
import '../../providers/address_store.dart';
import '../../providers/cart_store.dart';
import '../../providers/catalog_store.dart';
import '../../providers/member_store.dart';
import '../../providers/order_store.dart';
import '../../providers/outlet_store.dart';
import '../../providers/payment_store.dart';
import '../../providers/voucher_store.dart';
import '../../services/sync_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/checkout_sheets.dart';
import '../../widgets/ui.dart';
import '../order/order_status_screen.dart';
import '../outlet/outlet_picker_screen.dart';
import '../product/product_detail_screen.dart';
import 'payment_methods_screen.dart';
import 'qris_payment_screen.dart';
import 'voucher_pack_screen.dart';

/// Halaman **Checkout** (PRD F25–F35).
///
/// Diambil dari isi keranjang, bukan satu produk. Tata letaknya mengikuti
/// `docs/design.md` §11.5: header "Checkout", latar `0xFFFBFBFB`, lebar 430,
/// dan bottom bar "Jadwalkan" + "Bayar".
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  /// Biaya Kantung Belanja per pesanan (PRD F30).
  static const int bagFee = 200;

  final TextEditingController _voucherController = TextEditingController();

  bool _pakaiKantung = false;
  bool _pakaiPoin = false;
  Voucher? _voucher;
  String? _voucherError;
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  // --- Perhitungan -------------------------------------------------------

  int get _subtotal => CartStore.totalPrice;

  int get _bagFee => _pakaiKantung ? bagFee : 0;

  int get _voucherDiscount {
    final voucher = _voucher;
    if (voucher == null) return 0;

    return voucher.discountFor(_subtotal);
  }

  int get _maxPoints {
    final remaining = _subtotal + _bagFee - _voucherDiscount;
    if (remaining <= 0) return 0;

    final owned = MemberStore.points.value;
    return owned < remaining ? owned : remaining;
  }

  int get _pointsUsed => _pakaiPoin ? _maxPoints : 0;

  int get _total {
    final value = _subtotal + _bagFee - _voucherDiscount - _pointsUsed;
    return value < 0 ? 0 : value;
  }

  // --- Aksi --------------------------------------------------------------

  void _pakaiVoucher() {
    try {
      final voucher = VoucherStore.validateCode(_voucherController.text);
      setState(() {
        _voucher = voucher;
        _voucherError = null;
        _voucherController.text = voucher.code;
      });

      showAppMessage(context, 'Voucher ${voucher.title} dipakai.');
    } on VoucherException catch (error) {
      setState(() {
        _voucher = null;
        _voucherError = error.message;
      });
    }
  }

  Future<void> _jadwalkan() async {
    final hasil = await showScheduleSheet(context, initial: _scheduledAt);

    if (hasil == null) return;
    if (!mounted) return;

    setState(() => _scheduledAt = hasil);
    showAppMessage(context, 'Pesanan dijadwalkan pukul ${_formatTime(hasil)}.');
  }

  /// Membuat pesanan dari isi keranjang (PRD F36/F37), tanpa berpindah halaman.
  ///
  /// Kalau pengguna sedang masuk dan API aktif, pesanan dibuat di server
  /// lewat [SyncService.createOrder]; kalau tidak, pesanan dibuat di
  /// [OrderStore] seperti sebelumnya. Dipakai bersama oleh metode pembayaran
  /// non-QRIS dan tombol "Kembali Ke Beranda" di halaman QRIS.
  Future<Order> _buatPesanan() async {
    final items = List<CartItem>.from(CartStore.items.value);
    final fulfilment = OutletStore.mode.value.label;

    final remote = await SyncService.createOrder(
      items: items,
      bagFee: _bagFee,
      pointsUsed: _pointsUsed,
      paymentMethodId: PaymentStore.selected.id,
      fulfilment: fulfilment,
      outletId: _outletId(),
      scheduledAt: _scheduledAt,
      voucherCode: _voucher?.code,
    );

    final order =
        remote ??
        OrderStore.create(
          items: items,
          subtotal: _subtotal,
          bagFee: _bagFee,
          voucherDiscount: _voucherDiscount,
          pointsUsed: _pointsUsed,
          paymentMethod: PaymentStore.selected.name,
          fulfilment: fulfilment,
          scheduledAt: _scheduledAt,
        );

    CartStore.clear();

    return order;
  }

  /// Membuat pesanan, mengosongkan keranjang, lalu membuka halaman Status
  /// Pesanan (PRD F36/F37).
  ///
  /// Dipakai metode pembayaran non-QRIS. Pembayaran QRIS memakai
  /// [_selesaikanPesananKeBeranda] karena halamannya langsung kembali ke
  /// Beranda setelah pesanan dibuat.
  Future<void> _selesaikanPesanan() async {
    final order = await _buatPesanan();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderStatusScreen(orderId: order.id),
      ),
    );
  }

  /// Membuat pesanan lalu langsung kembali ke Beranda.
  ///
  /// Dipakai tombol "Kembali Ke Beranda" di [QrisPaymentScreen]: pesanan tetap
  /// tercatat di Riwayat Pesanan (status Pending), tetapi pembeli tidak
  /// dibawa ke halaman Status Pesanan.
  Future<void> _selesaikanPesananKeBeranda() async {
    await _buatPesanan();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Nomor outlet terpilih di server, berdasarkan urutan katalog outlet.
  int? _outletId() {
    final outlets = CatalogStore.outlets.value;
    final selected = OutletStore.selected.value.name;

    for (var index = 0; index < outlets.length; index++) {
      if (outlets[index].name == selected) return index + 1;
    }

    return null;
  }

  void _bayar() {
    if (CartStore.isEmpty) {
      showAppMessage(context, 'Keranjangmu masih kosong.');
      return;
    }

    if (PaymentStore.selected.id == 'qris') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrisPaymentScreen(
            total: _total,
            onPaid: _selesaikanPesananKeBeranda,
          ),
        ),
      );
      return;
    }

    _selesaikanPesanan();
  }

  String _formatTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');

    return '$day/$month · $hour.00';
  }

  // --- Bangun tampilan ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartStore.items,
      builder: (context, items, _) {
        return Scaffold(
          backgroundColor: AppColors.surfaceCheckout,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    _header(context),
                    Expanded(
                      child: items.isEmpty
                          ? AppEmptyState(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Keranjangmu masih kosong',
                              message:
                                  'Tambahkan menu favoritmu dulu untuk bisa '
                                  'checkout.',
                              actionLabel: 'Kembali',
                              onAction: () => Navigator.maybePop(context),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              children: [
                                _outletCard(context),
                                const SizedBox(height: 16),
                                _paymentSection(context),
                                const SizedBox(height: 16),
                                _orderCard(context, items),
                                const SizedBox(height: 16),
                                _shoppingBagCard(),
                                const SizedBox(height: 16),
                                _voucherCard(),
                                const SizedBox(height: 16),
                                _pointsCard(),
                                const SizedBox(height: 16),
                                _summaryCard(),
                                const SizedBox(height: 20),
                                _voucherPackageCard(context),
                              ],
                            ),
                    ),
                    if (items.isNotEmpty) _bottomBar(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, size: 24),
            tooltip: 'Kembali',
          ),
          const Expanded(
            child: Text(
              'Checkout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  /// Kartu outlet + mode Delivery/Pickup, dengan tautan "Ubah" ke halaman
  /// Pilih Outlet (PRD F7).
  Widget _outletCard(BuildContext context) {
    return ValueListenableBuilder<List<Address>>(
      valueListenable: AddressStore.addresses,
      builder: (context, addresses, _) => ValueListenableBuilder<Outlet>(
        valueListenable: OutletStore.selected,
        builder: (context, outlet, _) {
          return ValueListenableBuilder<FulfilmentMode>(
            valueListenable: OutletStore.mode,
            builder: (context, mode, _) {
              final pickup = mode == FulfilmentMode.pickup;

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.greenStoreBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          pickup ? Icons.storefront : Icons.delivery_dining,
                          color: AppColors.greenStorefront,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickup ? 'Pickup di Counter' : 'Delivery',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pickup ? outlet.name : _deliveryAddressLabel(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (pickup) {
                            showPickupConfirmSheet(context, outlet: outlet);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OutletPickerScreen(),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.checkoutRed,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(pickup ? 'Lihat' : 'Ubah'),
                      ),
                    ],
                  ),
                  if (_scheduledAt != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOption,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 18,
                            color: AppColors.checkoutRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dijadwalkan ${_formatTime(_scheduledAt!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _scheduledAt = null),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.checkoutRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
        },
      ),
    );
  }

  String _deliveryAddressLabel() {
    final address = AddressStore.defaultAddress;
    return address == null ? 'Belum ada alamat pengiriman' : address.detail;
  }

  /// Kartu metode pembayaran terpilih + "Lihat Semua" (PRD F34).
  Widget _paymentSection(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: PaymentStore.selectedId,
      builder: (context, selectedId, _) {
        final method = PaymentStore.selected;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PaymentMethodsScreen(selectMode: true),
                      ),
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueLink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
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
                            fontSize: 9,
                            color: AppColors.goldSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.checkoutRed,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// `true` kalau item ini merchandise.
  ///
  /// Merchandise tidak punya opsi kustomisasi, jadi tombol "Ganti" tidak
  /// ditampilkan — hanya jumlahnya yang bisa diubah.
  bool _isMerch(CartItem item) =>
      !item.hasDrinkOptions &&
      CatalogStore.merch.value.any((product) => product.name == item.name);

  /// Daftar item di keranjang, dengan ubah jumlah, Ganti, dan hapus
  /// (PRD F27–F29).
  Widget _orderCard(BuildContext context, List<CartItem> items) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesananmu (${CartStore.totalQuantity} item)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index++) ...[
            if (index > 0)
              const Divider(height: 22, color: AppColors.border),
            _itemRow(context, items[index], index),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, CartItem item, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Image.asset(
            item.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.local_cafe,
              size: 30,
              color: AppColors.maroon,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (item.customizationLines.isNotEmpty)
                Text(
                  item.customizationLines.join(' · '),
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _stepper(item, index),
                  const Spacer(),
                  Text(
                    formatRupiah(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (!_isMerch(item)) ...[
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: {
                              'name': item.name,
                              'price': formatRupiah(item.basePrice),
                              'image': item.image,
                              'description':
                                  'Kopi Kangenan pilihan, dibuat segar setiap '
                                  'pesanan.',
                            },
                            initial: item,
                            editIndex: index,
                            drinkOptions: item.hasDrinkOptions,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Ganti'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.checkoutRed,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      CartStore.removeAt(index);
                      showAppMessage(
                        context,
                        '${item.name} dihapus dari pesanan.',
                      );
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepper(CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSoft),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => CartStore.updateQuantity(index, item.quantity - 1),
            icon: const Icon(Icons.remove, size: 16),
            color: AppColors.gold,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
            tooltip: 'Kurangi',
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => CartStore.updateQuantity(index, item.quantity + 1),
            icon: const Icon(Icons.add, size: 16),
            color: AppColors.gold,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 40),
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }

  /// Opsi Kantung Belanja (PRD F30).
  Widget _shoppingBagCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: CheckboxListTile(
        value: _pakaiKantung,
        onChanged: (value) => setState(() => _pakaiKantung = value ?? false),
        activeColor: AppColors.maroon,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Kantung Belanja',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Pakai kantung belanja (+${formatRupiah(bagFee)})',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  /// Input kode voucher (PRD F32).
  Widget _voucherCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pakai Kode Voucher',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'mis. KANGENAN10',
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
                width: 92,
                child: AppPrimaryButton(
                  label: 'Pakai',
                  radius: 12,
                  background: AppColors.checkoutRed,
                  onPressed: _pakaiVoucher,
                ),
              ),
            ],
          ),
          if (_voucherError != null) ...[
            const SizedBox(height: 8),
            Text(
              _voucherError!,
              style: const TextStyle(fontSize: 12, color: AppColors.red),
            ),
          ],
          if (_voucher != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.greenBadgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 18,
                    color: AppColors.greenBadgeText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _voucher!.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenBadgeText,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _voucher = null;
                      _voucherController.clear();
                    }),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenBadgeText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Vouchermu tersimpan di tab Voucher halaman VIP, atau beli paket '
            'voucher di bawah.',
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Tukar Kangenan Points (PRD F31).
  Widget _pointsCard() {
    return ValueListenableBuilder<int>(
      valueListenable: MemberStore.points,
      builder: (context, points, _) {
        final bisa = points > 0;

        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: CheckboxListTile(
            value: _pakaiPoin && bisa,
            onChanged: bisa
                ? (value) => setState(() => _pakaiPoin = value ?? false)
                : null,
            activeColor: AppColors.maroon,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Pakai Kangenan Points',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              bisa
                  ? 'Punya $points pts — bisa memotong sampai '
                        '${formatRupiah(_maxPoints)}'
                  : 'Belum ada poin. Kumpulkan dari pesanan & Daily Check-In.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  /// Ringkasan pembayaran.
  Widget _summaryCard() {
    return AppCard(
      child: Column(
        children: [
          AppLabelValue(
            label: 'Subtotal',
            value: formatRupiah(_subtotal),
          ),
          if (_bagFee > 0)
            AppLabelValue(
              label: 'Kantung Belanja',
              value: formatRupiah(_bagFee),
            ),
          if (_voucherDiscount > 0)
            AppLabelValue(
              label: 'Voucher',
              value: '- ${formatRupiah(_voucherDiscount)}',
              valueColor: AppColors.green,
            ),
          if (_pointsUsed > 0)
            AppLabelValue(
              label: 'Kangenan Points',
              value: '- ${formatRupiah(_pointsUsed)}',
              valueColor: AppColors.green,
            ),
          const Divider(height: 20, color: AppColors.border),
          AppLabelValue(
            label: 'Total Pembayaran',
            value: formatRupiah(_total),
            bold: true,
          ),
        ],
      ),
    );
  }

  /// Ajak beli paket voucher (PRD F33).
  Widget _voucherPackageCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VoucherPackScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldVoucherBorder, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 42,
              color: AppColors.goldGift,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beli Paket Voucher',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lebih hemat! Voucher langsung masuk ke akunmu.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.action,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Beli',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderSoft),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _jadwalkan,
                icon: const Icon(Icons.schedule, size: 20),
                label: const Text(
                  'Jadwalkan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.checkoutRed,
                  side: const BorderSide(color: AppColors.checkoutRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _bayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.checkoutRed,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Bayar - ${formatRupiah(_total)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
