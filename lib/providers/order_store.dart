import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/order.dart';
import '../services/sync_service.dart';
import 'member_store.dart';

/// Riwayat pesanan (PRD F37/F38). Hanya di memori.
class OrderStore {
  OrderStore._();

  /// Nomor urut pesanan. Pesanan contoh memakai `#1001`, jadi pesanan berikutnya
  /// mulai dari `#1002` supaya tidak ada nomor yang kembar.
  static int _counter = 1002;
  static bool _seeded = false;

  static final ValueNotifier<List<Order>> orders =
      ValueNotifier<List<Order>>(<Order>[]);

  /// Membuat pesanan baru dari isi keranjang.
  ///
  /// Poin yang dipakai langsung dipotong, lalu belanja dicatat untuk poin dan
  /// level membership. Mengembalikan pesanan yang baru dibuat.
  static Order create({
    required List<CartItem> items,
    required int subtotal,
    required int bagFee,
    required int voucherDiscount,
    required int pointsUsed,
    required String paymentMethod,
    required String fulfilment,
    DateTime? scheduledAt,
  }) {
    _seedOnce();

    final total =
        (subtotal + bagFee - voucherDiscount - pointsUsed).clamp(0, 1 << 40);

    final order = Order(
      id: '#${_counter++}',
      items: items,
      subtotal: subtotal,
      bagFee: bagFee,
      pointsUsed: pointsUsed,
      voucherDiscount: voucherDiscount,
      total: total,
      paymentMethod: paymentMethod,
      fulfilment: fulfilment,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
    );

    orders.value = [order, ...orders.value];

    if (pointsUsed > 0) {
      MemberStore.redeemPoints(pointsUsed, 'Redeem poin pesanan ${order.id}');
    }
    MemberStore.registerSpend(total, order.id);

    return order;
  }

  /// Memajukan status pesanan satu langkah (Pending → Processing → Ready →
  /// Completed). Dipakai tombol "Pesanan sudah saya ambil".
  static void advance(String id) {
    orders.value = orders.value.map((order) {
      if (order.id != id || order.status.isFinal) return order;

      final next = switch (order.status) {
        OrderStatus.pending => OrderStatus.processing,
        OrderStatus.processing => OrderStatus.ready,
        OrderStatus.ready => OrderStatus.completed,
        _ => order.status,
      };

      return order.copyWith(status: next);
    }).toList();

    unawaited(SyncService.pushOrderAdvance(id));
  }

  static void cancel(String id) {
    orders.value = orders.value
        .map(
          (order) => order.id == id && !order.status.isFinal
              ? order.copyWith(status: OrderStatus.cancelled)
              : order,
        )
        .toList();

    unawaited(SyncService.pushOrderCancel(id));
  }

  /// Mengganti seluruh riwayat dengan data dari server, lalu menyesuaikan
  /// nomor urut pesanan berikutnya.
  static void replaceAll(List<Order> incoming) {
    _seeded = true;

    var highest = 1001;
    for (final order in incoming) {
      final number = int.tryParse(order.id.replaceAll('#', ''));
      if (number != null && number > highest) highest = number;
    }

    _counter = highest + 1;
    orders.value = incoming;
  }

  static Order? findById(String id) {
    for (final order in orders.value) {
      if (order.id == id) return order;
    }

    return null;
  }

  /// Menyiapkan satu pesanan lama supaya halaman Riwayat Pesanan tidak kosong
  /// saat pertama dibuka.
  static void _seedOnce() {
    if (_seeded) return;
    _seeded = true;

    orders.value = [
      Order(
        id: '#1001',
        items: const [
          CartItem(
            name: 'Taro Cloud Latte',
            image: 'assets/taro cloud latte.png',
            basePrice: 28000,
            quantity: 1,
            size: 'Regular',
            milk: 'Milk',
            sugar: 'Normal Sugar',
            ice: 'Normal Ice',
            toppings: <String>[],
            syrups: <String>[],
            unitPrice: 28000,
          ),
        ],
        subtotal: 28000,
        bagFee: 0,
        pointsUsed: 0,
        voucherDiscount: 0,
        total: 28000,
        paymentMethod: 'QRIS',
        fulfilment: 'Pickup',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: OrderStatus.completed,
      ),
    ];
  }

  /// Memastikan data contoh ikut muncul di tes maupun aplikasi.
  static void seed() => _seedOnce();

  static void clear() {
    orders.value = <Order>[];
    _counter = 1002;
    _seeded = false;
  }
}
