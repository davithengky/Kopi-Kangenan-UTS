import 'package:flutter/material.dart';

import '../../models/inbox.dart';
import '../../providers/inbox_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Kotak Masuk (PRD F5).
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<InboxMessage>>(
      valueListenable: InboxStore.messages,
      builder: (context, messages, _) {
        return AppPage(
          title: 'Kotak Masuk',
          actions: [
            if (messages.isNotEmpty)
              TextButton(
                onPressed: () {
                  InboxStore.markAllRead();
                  showAppMessage(context, 'Semua pesan ditandai sudah dibaca.');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.maroon,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Tandai Semua'),
              ),
          ],
          children: [
            if (messages.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Kotak masuk kosong',
                  message: 'Notifikasi promo dan status pesananmu muncul di sini.',
                ),
              )
            else
              for (final message in messages) ...[
                _messageCard(context, message),
                const SizedBox(height: 10),
              ],
          ],
        );
      },
    );
  }

  Widget _messageCard(BuildContext context, InboxMessage message) {
    return GestureDetector(
      onTap: () {
        InboxStore.markRead(message.id);
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: message.kind.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        message.kind.icon,
                        color: message.kind.color,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message.kind.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: message.kind.color,
                        ),
                      ),
                    ),
                    Text(
                      message.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  message.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message.body,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'Tutup',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: message.kind.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                message.kind.icon,
                color: message.kind.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: message.read
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!message.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.action,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                InboxStore.remove(message.id);
                showAppMessage(context, 'Pesan dihapus.');
              },
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textSecondary,
              visualDensity: VisualDensity.compact,
              tooltip: 'Hapus pesan',
            ),
          ],
        ),
      ),
    );
  }
}
