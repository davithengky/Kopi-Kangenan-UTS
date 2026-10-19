import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Jenis pesan di Kotak Masuk (PRD F5).
enum InboxKind {
  promo('Promo', Icons.local_offer_outlined, AppColors.action),
  pesanan('Pesanan', Icons.receipt_long_outlined, AppColors.green),
  akun('Akun', Icons.person_outline, AppColors.blueLink);

  const InboxKind(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// Satu notifikasi di Kotak Masuk.
class InboxMessage {
  final String id;
  final String title;
  final String body;
  final String date;
  final InboxKind kind;
  final bool read;

  const InboxMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.kind = InboxKind.promo,
    this.read = false,
  });

  InboxMessage copyWith({bool? read}) {
    return InboxMessage(
      id: id,
      title: title,
      body: body,
      date: date,
      kind: kind,
      read: read ?? this.read,
    );
  }
}
