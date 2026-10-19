import 'package:flutter/foundation.dart';

import '../models/cart.dart';

export '../models/cart.dart' show CartItem;

/// Isi keranjang belanja.
///
/// Sama seperti [AuthStore], semuanya hanya hidup di memori: menutup aplikasi
/// akan mengosongkan keranjang (lihat `docs/design.md` §2).
class CartStore {
  CartStore._();

  static final ValueNotifier<List<CartItem>> items =
      ValueNotifier<List<CartItem>>([]);

  static int get totalQuantity =>
      items.value.fold(0, (sum, item) => sum + item.quantity);

  static int get totalPrice =>
      items.value.fold(0, (sum, item) => sum + item.totalPrice);

  static bool get isEmpty => items.value.isEmpty;

  static void add(CartItem item) {
    items.value = [...items.value, item];
  }

  /// Mengubah jumlah sebuah item. Jumlah 0 atau kurang menghapus item itu.
  static void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= items.value.length) return;

    if (quantity <= 0) {
      removeAt(index);
      return;
    }

    final next = [...items.value];
    next[index] = next[index].copyWith(quantity: quantity);
    items.value = next;
  }

  /// Mengganti item ke-[index], dipakai saat pembeli menekan "Ganti".
  static void replaceAt(int index, CartItem item) {
    if (index < 0 || index >= items.value.length) return;

    final next = [...items.value];
    next[index] = item;
    items.value = next;
  }

  static void removeAt(int index) {
    if (index < 0 || index >= items.value.length) return;

    final next = [...items.value]..removeAt(index);
    items.value = next;
  }

  static void clear() {
    items.value = <CartItem>[];
  }
}
