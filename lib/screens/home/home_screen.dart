import 'package:flutter/material.dart';

import '../../models/outlet.dart';
import '../../models/product.dart';
import '../../providers/cart_store.dart';
import '../../providers/catalog_store.dart';
import '../../providers/member_store.dart';
import '../../providers/outlet_store.dart';
import '../../providers/voucher_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/diskon_cashback_section.dart';
import '../../widgets/kangenan_coin.dart';
import '../../widgets/outlet_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../cart/cart_screen.dart';
import '../merch/scan_merch_screen.dart';
import '../outlet/outlet_picker_screen.dart';
import '../product/product_detail_screen.dart';
import '../profile/bulk_order_screen.dart';

/// Beranda (PRD F6, F8–F12).
///
/// Susunannya tetap seperti `docs/design.md` §11.2. Yang baru hanya isi yang
/// sekarang hidup: level & poin di header, tombol keranjang, kartu outlet yang
/// bisa diketuk, menu pintas yang berfungsi, dan section "Spesial Hari Ini".
class HomeScreen extends StatelessWidget {
  /// Dipakai menu pintas untuk berpindah tab pada bottom navigation.
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.onSelectTab});

  void _ubahTab(int index) {
    final callback = onSelectTab;
    if (callback != null) callback(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context),

        // Banner promo
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: Image.asset(
            'assets/banner_promo.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Gambar gagal dimuat:\n$error',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            },
          ),
        ),

        // Menu pintas
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Row(
            children: [
              _QuickMenu(
                icon: Icons.shopping_bag,
                title: 'Order',
                color: AppColors.quickRed,
                onTap: () => _ubahTab(1),
              ),
              _QuickMenu(
                icon: Icons.delivery_dining,
                title: 'Delivery\nHemat',
                color: AppColors.quickOrange,
                onTap: () {
                  OutletStore.setMode(FulfilmentMode.delivery);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OutletPickerScreen(),
                    ),
                  );
                },
              ),
              _QuickMenu(
                icon: Icons.lunch_dining,
                title: 'Chicken &\nBurger',
                color: AppColors.quickPeach,
                onTap: () => _ubahTab(1),
              ),
              _QuickMenu(
                icon: Icons.card_giftcard,
                title: 'Catering &\nWedding',
                color: AppColors.quickGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BulkOrderScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Voucher
        _voucherCard(context),

        // Paket Hemat
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Paket Hemat',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: const [
              _SpecialCard(
                title: 'PaHe 1',
                price: 'Rp19.000',
                image: 'assets/pahe1.png',
                color: Colors.white,
              ),
              _SpecialCard(
                title: 'PaHe 2',
                price: 'Rp27.000',
                image: 'assets/pahe2.png',
                color: Colors.white,
              ),
              _SpecialCard(
                title: 'PaHe 3',
                price: 'Rp29.000',
                image: 'assets/pahe3.png',
                color: Colors.white,
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        DiskonCashbackSection(
          horizontalPadding: 20,
          onKlaim: (label) {
            VoucherStore.claimPromo(label);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Promo $label berhasil diklaim!')),
            );
          },
        ),

        // Spesial Hari Ini
        const SizedBox(height: 26),
        const SectionHeader(
          title: 'Spesial Hari Ini',
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
        ),
        _specialToday(context),

        const SizedBox(height: 26),
        const SectionHeader(
          title: 'Baru!',
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _productGrid(context, CatalogStore.menuByCategory('Baru!')),
        ),

        const SizedBox(height: 28),
        const SectionHeader(
          title: 'Makanan',
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _productGrid(context, CatalogStore.menuByCategory('Makanan')),
        ),

        const SizedBox(height: 28),
      ],
    );
  }

  /// Header: level & poin dari [MemberStore], keranjang, dan kartu outlet yang
  /// bisa diketuk (PRD F6/F9).
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              ValueListenableBuilder<int>(
                valueListenable: MemberStore.totalSpent,
                builder: (context, spent, _) => Text(
                  '${MemberStore.level.label}  '
                  '${(MemberStore.levelProgress * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<int>(
                valueListenable: MemberStore.points,
                builder: (context, points, _) => Row(
                  children: [
                    // Koin "K" Kangenan, bukan ikon dolar.
                    const KangenanCoin(
                      size: 24,
                      color: AppColors.coinYellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$points pts',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _cartButton(context),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<Outlet>(
            valueListenable: OutletStore.selected,
            builder: (context, outlet, _) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OutletPickerScreen(),
                ),
              ),
              child: OutletCard(
                outlet: outlet,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.maroon,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanMerchScreen(),
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('Melayani', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              SizedBox(width: 12),
              Icon(Icons.circle, color: AppColors.greenDelivery, size: 10),
              SizedBox(width: 5),
              Text('Delivery', style: TextStyle(fontSize: 13)),
              SizedBox(width: 15),
              Icon(Icons.circle, color: AppColors.greenPickup, size: 10),
              SizedBox(width: 5),
              Text('Pickup', style: TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  /// Tombol keranjang dengan jumlah item.
  Widget _cartButton(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartStore.items,
      builder: (context, items, _) {
        final count = CartStore.totalQuantity;

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                  color: AppColors.maroon,
                ),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.action,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Kartu klaim voucher Buy 1 Get 1 (PRD F10).
  Widget _voucherCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.goldVoucherBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard,
            color: AppColors.goldGift,
            size: 42,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Voucher Buy 1 Get 1\nSEPUASNYA!',
              style: TextStyle(
                fontSize: 14,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              VoucherStore.claimPromo('Buy 1 Get 1');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voucher Buy 1 Get 1 berhasil diklaim!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.action,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(
              VoucherStore.hasClaimedBuyOneGetOne ? 'Diklaim' : 'Klaim',
            ),
          ),
        ],
      ),
    );
  }

  /// Section "Spesial Hari Ini": carousel produk promo memakai komponen kartu
  /// yang sudah ada (`ProductCardHorizontal`, §10.23).
  Widget _specialToday(BuildContext context) {
    final products = CatalogStore.menuByCategory('Promo & Combo');

    return SizedBox(
      height: 216,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return ProductCardHorizontal(
            product: product,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(product: product.toProductMap()),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Grid produk 2 kolom untuk section di Beranda.
  Widget _productGrid(BuildContext context, List<Product> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 24,
          children: products
              .map(
                (product) => SizedBox(
                  width: itemWidth,
                  child: ProductCardGrid(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product.toProductMap(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _QuickMenu({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.maroon, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final Color color;

  const _SpecialCard({
    required this.title,
    required this.price,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        // Deskripsi dan klasifikasi diambil dari katalog supaya halaman
        // detailnya sama dengan kartu produk di tempat lain.
        final matches = kProductCatalog.where((item) => item.name == title);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: matches.isEmpty
                  ? {'name': title, 'price': price, 'image': image}
                  : matches.first.toProductMap(),
              drinkOptions: true,
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.local_cafe, size: 38, color: color);
                  },
                ),
              ),
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(price, style: const TextStyle(color: AppColors.maroon)),
          ],
        ),
      ),
    );
  }
}
