import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../providers/order_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';

/// Halaman Status Pesanan (PRD F37).
class OrderStatusScreen extends StatelessWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  static const List<OrderStatus> _steps = [
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: OrderStore.orders,
      builder: (context, orders, _) {
        final order = OrderStore.findById(orderId);
        if (order == null) {
          return AppPage(
            title: 'Status Pesanan',
            scrollable: false,
            children: [
              Expanded(
                child: AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pesanan tidak ditemukan',
                  message: 'Pesanan ini sudah tidak tersedia di riwayat.',
                  actionLabel: 'Kembali',
                  onAction: () => Navigator.maybePop(context),
                ),
              ),
            ],
          );
        }

        return AppPage(
          title: 'Status Pesanan',
          bottomBar: order.status.isFinal
              ? null
              : AppBottomBar(
                  child: AppPrimaryButton(
                    label: order.status == OrderStatus.ready
                        ? 'Pesanan Sudah Saya Ambil'
                        : 'Perbarui Status Pesanan',
                    onPressed: () {
                      OrderStore.advance(order.id);
                      final updated = OrderStore.findById(order.id);
                      showAppMessage(
                        context,
                        'Status pesanan: ${updated?.status.label ?? '-'}',
                      );
                    },
                  ),
                ),
          children: [
            _statusCard(context, order),
            const SizedBox(height: 16),
            _stepsCard(order),
            const SizedBox(height: 16),
            _itemsCard(order),
            const SizedBox(height: 16),
            _summaryCard(order),
            const SizedBox(height: 16),
            AppOutlineButton(
              label: 'Hubungi Outlet',
              icon: Icons.support_agent,
              onPressed: () => showAppMessage(
                context,
                'Menghubungi outlet ${order.fulfilment.toLowerCase()}… '
                'Nomor pesanan ${order.id}.',
              ),
            ),
            const SizedBox(height: 10),
            if (!order.status.isFinal)
              AppOutlineButton(
                label: 'Batalkan Pesanan',
                icon: Icons.cancel_outlined,
                color: AppColors.red,
                onPressed: () {
                  OrderStore.cancel(order.id);
                  showAppMessage(context, 'Pesanan ${order.id} dibatalkan.');
                },
              ),
          ],
        );
      },
    );
  }

  Widget _statusCard(BuildContext context, Order order) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: order.status.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(order.status),
              color: order.status.color,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            order.status.label,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: order.status.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _estimate(order),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nomor pesanan ${order.id}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard(Order order) {
    final activeIndex = _steps.indexOf(order.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perjalanan pesanan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < _steps.length; i++)
            _stepRow(_steps[i], done: activeIndex >= i && activeIndex >= 0),
        ],
      ),
    );
  }

  Widget _stepRow(OrderStatus status, {required bool done}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? AppColors.green : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check : Icons.circle,
              size: done ? 15 : 8,
              color: done ? Colors.white : AppColors.disabled,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: done ? FontWeight.bold : FontWeight.normal,
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsCard(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail pesanan (${order.totalQuantity} item)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.quantity}x',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.customizationLines.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.customizationLines.join(' · '),
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(formatRupiah(item.totalPrice)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(Order order) {
    return AppCard(
      child: Column(
        children: [
          AppLabelValue(
            label: 'Subtotal',
            value: formatRupiah(order.subtotal),
          ),
          if (order.bagFee > 0)
            AppLabelValue(
              label: 'Kantung Belanja',
              value: formatRupiah(order.bagFee),
            ),
          if (order.voucherDiscount > 0)
            AppLabelValue(
              label: 'Voucher',
              value: '- ${formatRupiah(order.voucherDiscount)}',
              valueColor: AppColors.green,
            ),
          if (order.pointsUsed > 0)
            AppLabelValue(
              label: 'Poin dipakai',
              value: '- ${formatRupiah(order.pointsUsed)}',
              valueColor: AppColors.green,
            ),
          const Divider(height: 20, color: AppColors.border),
          AppLabelValue(
            label: 'Total Pembayaran',
            value: formatRupiah(order.total),
            bold: true,
          ),
          const SizedBox(height: 8),
          AppLabelValue(label: 'Pembayaran', value: order.paymentMethod),
          AppLabelValue(label: 'Tipe', value: order.fulfilment),
          if (order.scheduledAt != null)
            AppLabelValue(
              label: 'Dijadwalkan',
              value: _formatDateTime(order.scheduledAt!),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');

    return '$day/$month/${value.year} · $hour.00';
  }

  String _estimate(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Pesanan diterima. Outlet akan mulai menyiapkan pesananmu.';
      case OrderStatus.processing:
        return 'Pesananmu sedang dibuat. Estimasi 5-10 menit.';
      case OrderStatus.ready:
        return 'Pesanan siap! Ambil di area pickup outlet pilihanmu.';
      case OrderStatus.completed:
        return 'Pesanan sudah selesai. Terima kasih sudah memesan!';
      case OrderStatus.cancelled:
        return 'Pesanan ini dibatalkan.';
    }
  }

  IconData _iconFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top;
      case OrderStatus.processing:
        return Icons.local_cafe_outlined;
      case OrderStatus.ready:
        return Icons.shopping_bag_outlined;
      case OrderStatus.completed:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
