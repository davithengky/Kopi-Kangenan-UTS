import 'package:flutter/foundation.dart';

import '../models/merch.dart';
import '../models/outlet.dart';
import '../models/product.dart';

/// Katalog yang sedang dipakai aplikasi.
///
/// Nilai awalnya sama persis dengan data bawaan di `models/`
/// (`kProductCatalog`, `kMerchCatalog`, `kOutlets`), lalu diperbarui dari REST
/// API saat aplikasi dibuka. Karena nilai awalnya sudah benar, aplikasi tetap
/// tampil normal walau API sedang tidak bisa dihubungi.
class CatalogStore {
  const CatalogStore._();

  /// Urutan kategori pada katalog menu.
  static const List<String> categoryOrder = [
    'Promo & Combo',
    'Baru!',
    'Coffee',
    'Non Coffee',
    'Makanan',
  ];

  /// Produk menu, sudah dipecah per kategori seperti `kProductCatalog`
  /// (satu produk bisa muncul di beberapa kategori).
  static final ValueNotifier<List<Product>> menu = ValueNotifier<List<Product>>(
    kProductCatalog,
  );

  static final ValueNotifier<List<MerchProduct>> merch =
      ValueNotifier<List<MerchProduct>>(kMerchCatalog);

  static final ValueNotifier<List<Outlet>> outlets =
      ValueNotifier<List<Outlet>>(kOutlets);

  /// Produk menu pada kategori tertentu.
  static List<Product> menuByCategory(String category) => menu.value
      .where((product) => product.category == category)
      .toList();

  /// Mengembalikan katalog ke data bawaan. Dipakai oleh pengujian.
  static void reset() {
    menu.value = kProductCatalog;
    merch.value = kMerchCatalog;
    outlets.value = kOutlets;
  }
}
