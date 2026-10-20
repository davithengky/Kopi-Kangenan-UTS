import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../providers/cart_store.dart';
import '../../providers/order_store.dart';
import '../../providers/outlet_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';
import '../cart/cart_screen.dart';
import 'order_status_screen.dart';

/// Halaman Riwayat Pesanan (PRD F38).
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  /// `null` berarti filter "Semua".
  OrderStatus? filter;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: OrderStore.orders,
      builder: (context, orders, _) {
        final shown = filter == null
            ? orders
            : orders.where((order) => order.status == filter).toList();

        return AppPage(
          title: 'Riwayat Pesanan',
          children: [
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('Semua', filter == null, () {
                    setState(() => filter = null);
                  }),
                  for (final status in OrderStatus.values)
                    _chip(status.label, filter == status, () {
                      setState(() => filter = status);
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pesanan',
                  message: filter == null
                      ? 'Semua pesananmu akan muncul di sini setelah checkout.'
                      : 'Tidak ada pesanan dengan status ${filter!.label}.',
                ),
              )
            else
              for (final order in shown) ...[
                _orderCard(context, order),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.maroon : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.maroon : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.id} · ${_formatDate(order.createdAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.fulfilment} · ${order.paymentMethod}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: order.status.color,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.border),
          Text(
            order.items
                .map((item) => '${item.quantity}x ${item.name}')
                .join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.storefront,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  OutletStore.selected.value.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderStatusScreen(orderId: order.id),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.maroon,
                    side: const BorderSide(color: AppColors.borderSoft),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Lihat Status'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    for (final item in order.items) {
                      CartStore.add(item);
                    }

                    showAppMessage(context, 'Pesanan ditambahkan ke keranjang.');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.action,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Pesan Lagi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }
}
