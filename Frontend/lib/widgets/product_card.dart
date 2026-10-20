import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';

/// Badge hijau yang menempel di sudut gambar produk.
///
/// Dipakai untuk "New", "Promo Delivery", dan label promo lain.
class PromoBadge extends StatelessWidget {
  final String label;

  const PromoBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.green,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Harga dalam pill pink dengan ikon tag merah.
///
/// Dipakai pada kartu produk bentuk carousel (mis. kategori "Promo & Combo").
class PricePill extends StatelessWidget {
  final String price;

  const PricePill({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, size: 12, color: AppColors.red),
          const SizedBox(width: 5),
          Text(
            price,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gambar produk dengan fallback ikon bila berkasnya gagal dimuat.
class _ProductImage extends StatelessWidget {
  final String image;

  const _ProductImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.local_cafe, size: 46, color: AppColors.maroon),
      ),
    );
  }
}

/// Kartu produk untuk section berbentuk grid 2 kolom.
///
/// Struktur mengikuti aplikasi referensi: gambar polos (tanpa latar kartu),
/// badge "New" menempel di kiri bawah gambar, nama, lalu harga polos.
class ProductCardGrid extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardGrid({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(child: _ProductImage(image: product.image)),
                if (product.isNew)
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: PromoBadge(label: 'New'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.priceLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu produk untuk section berbentuk carousel horizontal.
///
/// Struktur mengikuti aplikasi referensi: gambar dengan badge promo yang
/// menempel di kiri bawah, nama, lalu harga dalam pill pink.
class ProductCardHorizontal extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardHorizontal({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 158,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 136,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: _ProductImage(image: product.image)),
                  if (product.promoLabel.isNotEmpty)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: PromoBadge(label: product.promoLabel),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: PricePill(price: product.priceLabel),
            ),
          ],
        ),
      ),
    );
  }
}
