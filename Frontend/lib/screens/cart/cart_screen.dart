import 'package:flutter/material.dart';

import '../../models/outlet.dart';
import '../../providers/cart_store.dart';
import '../../providers/catalog_store.dart';
import '../../providers/outlet_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';
import '../checkout/order_confirmation_screen.dart';
import '../outlet/outlet_picker_screen.dart';
import '../product/product_detail_screen.dart';

/// Halaman Keranjang (PRD F24–F29).
///
/// Menampilkan semua item yang sudah ditambahkan, lengkap dengan tombol ubah
/// jumlah, "Ganti" kustomisasi, dan hapus item.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  /// `true` kalau item ini merchandise.
  ///
  /// Merchandise tidak punya opsi kustomisasi sama sekali, jadi tombol "Ganti"
  /// tidak perlu ditampilkan — hanya jumlahnya yang bisa diubah.
  bool _isMerch(CartItem item) =>
      !item.hasDrinkOptions &&
      CatalogStore.merch.value.any((product) => product.name == item.name);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartStore.items,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return AppPage(
            title: 'Keranjang',
            scrollable: false,
            children: [
              Expanded(
                child: AppEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Keranjangmu masih kosong',
                  message:
                      'Yuk pilih kopi kangenan favoritmu dulu, lalu kembali '
                      'ke sini untuk menyelesaikan pesanan.',
                  actionLabel: 'Mulai Pesan',
                  onAction: () => Navigator.maybePop(context),
                ),
              ),
            ],
          );
        }

        return AppPage(
          title: 'Keranjang',
          bottomBar: AppBottomBar(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatRupiah(CartStore.totalPrice),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: AppPrimaryButton(
                    label: 'Checkout (${CartStore.totalQuantity})',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderConfirmationScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            _outletStrip(context),
            const SizedBox(height: 12),
            for (int index = 0; index < items.length; index++) ...[
              _itemCard(context, items[index], index),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Harga belum termasuk biaya Kantung Belanja. '
                      'Atur di halaman checkout.',
                      style: TextStyle(fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _outletStrip(BuildContext context) {
    return ValueListenableBuilder<Outlet>(
      valueListenable: OutletStore.selected,
      builder: (context, outlet, _) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OutletPickerScreen()),
        ),
        child: AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.maroon, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ambil di',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      outlet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Ubah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context, CartItem item, int index) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: Image.asset(
                  item.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_cafe,
                    size: 34,
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(item.unitPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.border),
          Row(
            children: [
              _quantityStepper(context, item, index),
              const Spacer(),
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
                              'Kopi Kangenan pilihan, dibuat segar setiap pesanan.',
                        },
                        initial: item,
                        editIndex: index,
                        drinkOptions: item.hasDrinkOptions,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Ganti'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              IconButton(
                onPressed: () {
                  CartStore.removeAt(index);
                  showAppMessage(context, '${item.name} dihapus dari keranjang.');
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.red,
                tooltip: 'Hapus item',
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Subtotal ${formatRupiah(item.totalPrice)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityStepper(BuildContext context, CartItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSoft),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => CartStore.updateQuantity(index, item.quantity - 1),
            icon: const Icon(Icons.remove, size: 18),
            color: AppColors.maroon,
            visualDensity: VisualDensity.compact,
            tooltip: 'Kurangi',
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => CartStore.updateQuantity(index, item.quantity + 1),
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.maroon,
            visualDensity: VisualDensity.compact,
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }
}
