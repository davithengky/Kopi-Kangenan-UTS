import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/point_entry.dart';
import '../services/sync_service.dart';

/// Level membership beserta ambang belanjanya (PRD F43).
enum MemberLevel {
  silver('Silver', 0, 700000, 'hati'),
  gold('Gold', 700000, 9999999, 'kunci'),
  black('Black', 9999999, 0, 'kunci hitam');

  const MemberLevel(this.label, this.minSpend, this.nextThreshold, this.iconKey);

  final String label;
  final int minSpend;

  /// Belanja yang dibutuhkan untuk naik ke level berikutnya (0 = level tertinggi).
  final int nextThreshold;
  final String iconKey;

  MemberLevel get next => switch (this) {
    MemberLevel.silver => MemberLevel.gold,
    MemberLevel.gold => MemberLevel.black,
    MemberLevel.black => MemberLevel.black,
  };

  bool get isHighest => this == MemberLevel.black;
}

/// Level, poin, dan Daily Check-In (PRD F44/F45).
class MemberStore {
  MemberStore._();

  /// Poin yang dimiliki. 1 poin = Rp1 saat diredeem (PRD F45).
  static final ValueNotifier<int> points = ValueNotifier<int>(0);

  /// Total belanja untuk menghitung level membership.
  static final ValueNotifier<int> totalSpent = ValueNotifier<int>(0);

  /// Nomor hari yang sudah check-in pada bulan ini (1–6).
  static final ValueNotifier<Set<int>> checkedDays =
      ValueNotifier<Set<int>>(<int>{});

  static final ValueNotifier<List<PointEntry>> history =
      ValueNotifier<List<PointEntry>>(<PointEntry>[]);

  /// Hadiah tiap hari; indeks 0 = Hari 1.
  static const List<String> dailyRewards = [
    '+25 poin',
    '+25 poin',
    'Voucher',
    '+25 poin',
    '+25 poin',
    'Voucher',
  ];

  static const int maxCheckInDays = 6;

  static MemberLevel get level {
    if (totalSpent.value >= MemberLevel.black.minSpend) return MemberLevel.black;
    if (totalSpent.value >= MemberLevel.gold.minSpend) return MemberLevel.gold;
    return MemberLevel.silver;
  }

  /// Progres menuju level berikutnya, 0.0–1.0. Level tertinggi selalu 1.0.
  static double get levelProgress {
    final current = level;
    if (current.isHighest) return 1;

    final base = current.minSpend;
    final range = current.nextThreshold - base;
    if (range <= 0) return 1;

    final progress = (totalSpent.value - base) / range;
    return progress.clamp(0.0, 1.0);
  }

  /// Sisa belanja untuk naik level, atau 0 kalau sudah level tertinggi.
  static int get remainingToNextLevel {
    final current = level;
    if (current.isHighest) return 0;

    final remaining = current.nextThreshold - totalSpent.value;
    return remaining < 0 ? 0 : remaining;
  }

  static bool get canCheckInToday =>
      checkedDays.value.length < maxCheckInDays && points.value >= 0;

  /// Melakukan check-in hari ini. Mengembalikan keterangan hadiahnya.
  static String checkIn() {
    if (!canCheckInToday) return 'Kamu sudah check-in 6 hari. Sampai jumpa bulan depan!';

    final day = checkedDays.value.length + 1;
    final reward = dailyRewards[day - 1];

    checkedDays.value = {...checkedDays.value, day};

    if (reward.contains('poin')) {
      final amount = int.parse(reward.replaceAll(RegExp(r'[^0-9]'), ''));
      addPoints(amount, 'Daily Check-In hari ke-$day');
    } else {
      history.value = [
        PointEntry(title: 'Daily Check-In hari ke-$day', date: 'Hari ini', delta: 0),
        ...history.value,
      ];
    }

    unawaited(SyncService.pushCheckIn());

    return reward;
  }

  /// Menambah poin beserta catatan riwayatnya.
  static void addPoints(int amount, String title) {
    if (amount == 0) return;

    points.value = points.value + amount;
    history.value = [
      PointEntry(title: title, date: 'Hari ini', delta: amount),
      ...history.value,
    ];
  }

  /// Memakai poin saat checkout.
  static void redeemPoints(int amount, String title) {
    final used = amount > points.value ? points.value : amount;
    if (used <= 0) return;

    points.value = points.value - used;
    history.value = [
      PointEntry(title: title, date: 'Hari ini', delta: -used),
      ...history.value,
    ];
  }

  /// Mencatat belanja dan poin yang didapat dari sebuah pesanan.
  ///
  /// Pembeli mendapat 1 poin untuk setiap Rp1.000 belanja.
  static int registerSpend(int total, String orderId) {
    totalSpent.value = totalSpent.value + total;

    final earned = total ~/ 1000;
    if (earned > 0) {
      addPoints(earned, 'Belanja pesanan $orderId');
    }

    return earned;
  }

  static void reset() {
    points.value = 0;
    totalSpent.value = 0;
    checkedDays.value = <int>{};
    history.value = <PointEntry>[];
  }
}
