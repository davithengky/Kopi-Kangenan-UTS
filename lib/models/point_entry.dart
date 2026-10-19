/// Satu baris riwayat poin (PRD F45).
class PointEntry {
  final String title;
  final String date;

  /// Positif kalau dapat poin, negatif kalau dipakai.
  final int delta;

  const PointEntry({
    required this.title,
    required this.date,
    required this.delta,
  });
}
