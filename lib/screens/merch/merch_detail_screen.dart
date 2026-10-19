import 'package:flutter/material.dart';

import '../../models/merch.dart';
import '../../providers/cart_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';
import '../cart/cart_screen.dart';

/// Halaman Detail Merchandise (PRD F47).
class MerchDetailScreen extends StatelessWidget {
  final MerchProduct product;

  const MerchDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Detail Merchandise',
      padding: EdgeInsets.zero,
      bottomBar: AppBottomBar(
        child: AppPrimaryButton(
          label: 'Tambah ke Keranjang',
          icon: Icons.shopping_bag_outlined,
          onPressed: () {
            CartStore.add(
              CartItem(
                name: product.name,
                image: product.image,
                basePrice: product.price,
                quantity: 1,
                size: '',
                milk: '',
                sugar: '',
                ice: '',
                toppings: const <String>[],
                syrups: const <String>[],
                unitPrice: product.price,
              ),
            );

            showAppMessage(context, '${product.name} masuk keranjang.');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Gratis Ukir',
                  style: TextStyle(
                    color: AppColors.greenBadgeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 26, color: AppColors.border),
                const AppLabelValue(label: 'Satuan', value: '1 pcs'),
                const AppLabelValue(
                  label: 'Pengiriman',
                  value: 'Pickup di outlet',
                ),
                const AppLabelValue(
                  label: 'Kustomisasi',
                  value: 'Bisa diukir nama',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
