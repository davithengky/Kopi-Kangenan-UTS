import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'cart.dart';

/// Status pesanan (PRD F37).
enum OrderStatus {
  pending('Pending', AppColors.warning),
  processing('Processing', AppColors.blueLink),
  ready('Ready', AppColors.green),
  completed('Completed', AppColors.textSecondary),
  cancelled('Cancelled', AppColors.action);

  const OrderStatus(this.label, this.color);

  final String label;
  final Color color;

  /// Kalau true, pembeli sudah tidak bisa membatalkan pesanan.
  bool get isFinal => this == completed || this == cancelled;
}

/// Pesanan yang sudah dibuat (PRD F36–F38).
class Order {
  final String id;
  final List<CartItem> items;
  final int subtotal;
  final int bagFee;
  final int pointsUsed;
  final int voucherDiscount;
  final int total;
  final String paymentMethod;
  final String fulfilment;
  final DateTime createdAt;
  final OrderStatus status;

  /// Diisi kalau pembeli menjadwalkan pesanan.
  final DateTime? scheduledAt;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.bagFee,
    required this.pointsUsed,
    required this.voucherDiscount,
    required this.total,
    required this.paymentMethod,
    required this.fulfilment,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.scheduledAt,
  });

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      items: items,
      subtotal: subtotal,
      bagFee: bagFee,
      pointsUsed: pointsUsed,
      voucherDiscount: voucherDiscount,
      total: total,
      paymentMethod: paymentMethod,
      fulfilment: fulfilment,
      createdAt: createdAt,
      status: status ?? this.status,
      scheduledAt: scheduledAt,
    );
  }
}
