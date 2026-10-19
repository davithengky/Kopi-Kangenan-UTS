import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/inbox.dart';
import '../services/sync_service.dart';

/// Kotak Masuk notifikasi (PRD F5), hanya di memori.
class InboxStore {
  InboxStore._();

  static final ValueNotifier<List<InboxMessage>> messages =
      ValueNotifier<List<InboxMessage>>([
        const InboxMessage(
          id: 'msg-1',
          title: 'Selamat datang di Kopi Kangenan!',
          body:
              'Terima kasih sudah mengunduh aplikasi kami. Cek promo terbaru '
              'di Beranda, ya!',
          date: 'Hari ini',
          kind: InboxKind.akun,
        ),
        const InboxMessage(
          id: 'msg-2',
          title: 'Voucher Buy 1 Get 1',
          body:
              'Klaim voucher Buy 1 Get 1 sepuasnya sebelum 31 Okt 2026. '
              'Berlaku di semua outlet.',
          date: 'Kemarin',
          kind: InboxKind.promo,
        ),
        const InboxMessage(
          id: 'msg-3',
          title: 'Pesananmu sudah siap',
          body:
              'Pesanan #1002 sudah siap diambil di counter Tunjungan Plaza 3.',
          date: '2 hari lalu',
          kind: InboxKind.pesanan,
          read: true,
        ),
      ]);

  static int get unreadCount =>
      messages.value.where((message) => !message.read).length;

  static void markRead(String id) {
    messages.value = messages.value
        .map((message) => message.id == id ? message.copyWith(read: true) : message)
        .toList();

    unawaited(SyncService.pushInboxRead(id));
  }

  static void markAllRead() {
    messages.value = messages.value
        .map((message) => message.copyWith(read: true))
        .toList();

    unawaited(SyncService.pushInboxReadAll());
  }

  /// Mengganti seluruh daftar dengan data dari server.
  static void replaceAll(List<InboxMessage> incoming) {
    messages.value = incoming;
  }

  static void remove(String id) {
    messages.value = messages.value.where((message) => message.id != id).toList();
  }

  static void add(InboxMessage message) {
    messages.value = [message, ...messages.value];
  }

  static void reset() {
    messages.value = [
      const InboxMessage(
        id: 'msg-1',
        title: 'Selamat datang di Kopi Kangenan!',
        body:
            'Terima kasih sudah mengunduh aplikasi kami. Cek promo terbaru '
            'di Beranda, ya!',
        date: 'Hari ini',
        kind: InboxKind.akun,
      ),
      const InboxMessage(
        id: 'msg-2',
        title: 'Voucher Buy 1 Get 1',
        body:
            'Klaim voucher Buy 1 Get 1 sepuasnya sebelum 31 Okt 2026. '
            'Berlaku di semua outlet.',
        date: 'Kemarin',
        kind: InboxKind.promo,
      ),
      const InboxMessage(
        id: 'msg-3',
        title: 'Pesananmu sudah siap',
        body:
            'Pesanan #1002 sudah siap diambil di counter Tunjungan Plaza 3.',
        date: '2 hari lalu',
        kind: InboxKind.pesanan,
        read: true,
      ),
    ];
  }
}
