/// Jenis voucher, dipakai untuk filter di tab Voucher VIP.
enum VoucherKind {
  diskon('Diskon'),
  cashback('Cashback'),
  delivery('Delivery'),
  gratis('Gratis');

  const VoucherKind(this.label);

  final String label;
}

/// Voucher yang dimiliki pembeli (hasil klaim promo atau beli paket).
class Voucher {
  final String code;
  final String title;
  final String description;
  final int minPurchase;
  final String validity;
  final VoucherKind kind;

  /// Potongan dalam persen (mis. 10 berarti 10%). Nol berarti tidak dipakai.
  final int percent;

  /// Potongan tetap dalam rupiah. Nol berarti tidak dipakai.
  final int amount;

  const Voucher({
    required this.code,
    required this.title,
    required this.description,
    this.minPurchase = 0,
    this.validity = 'Berlaku s/d 31 Des 2026',
    this.kind = VoucherKind.diskon,
    this.percent = 0,
    this.amount = 0,
  });

  /// Potongan yang diberikan untuk [subtotal], dibatasi jumlahnya.
  int discountFor(int subtotal) {
    if (subtotal < minPurchase && minPurchase > 0) return 0;

    if (percent > 0) {
      final value = (subtotal * percent) ~/ 100;
      return value > subtotal ? subtotal : value;
    }

    return amount > subtotal ? subtotal : amount;
  }

  /// `true` kalau voucher benar-benar mengurangi total untuk [subtotal].
  bool isApplicable(int subtotal) => discountFor(subtotal) > 0;
}

/// Paket voucher yang bisa dibeli (PRD F33/F41).
class VoucherPack {
  final String id;
  final String title;
  final String description;
  final int oldPrice;
  final int price;
  final String saving;
  final String count;

  const VoucherPack({
    required this.id,
    required this.title,
    required this.description,
    required this.oldPrice,
    required this.price,
    required this.saving,
    required this.count,
  });
}

/// Paket voucher yang tersedia. Dipakai bersama oleh Checkout dan tab VIP.
const List<VoucherPack> kVoucherPacks = [
  VoucherPack(
    id: 'pack-9000',
    title: 'Langganan Voucher Rp9.000',
    description:
        '1x Voucher B1G1, 2x Voucher B2G1, 30x Voucher Diskon 10%, '
        '30x Voucher Diskon 15%.',
    oldPrice: 630000,
    price: 9000,
    saving: 'Save 98%',
    count: '65x',
  ),
  VoucherPack(
    id: 'pack-24000',
    title: 'Langganan Voucher Rp24.000',
    description:
        '1x Voucher Gratis 1 Minuman, 1x Voucher B1G1, 2x Voucher B2G1, '
        '30x Voucher Diskon 10%, 30x Voucher Diskon 15%.',
    oldPrice: 680000,
    price: 24000,
    saving: 'Save 96%',
    count: '66x',
  ),
];

/// Voucher bawaan yang diberikan tiap paket saat dibeli.
List<Voucher> vouchersFromPack(VoucherPack pack) {
  return [
    Voucher(
      code: '${pack.id}-10',
      title: 'Voucher Diskon 10%',
      description: 'Diskon 10% untuk pembelian minuman pilihan.',
      minPurchase: 30000,
      percent: 10,
      kind: VoucherKind.diskon,
    ),
    Voucher(
      code: '${pack.id}-2k',
      title: 'Voucher Potongan Rp2.000',
      description: 'Potongan langsung Rp2.000 tanpa minimum pembelian.',
      amount: 2000,
      kind: VoucherKind.diskon,
    ),
    Voucher(
      code: '${pack.id}-gratis',
      title: 'Voucher Gratis 1 Minuman',
      description: 'Nikmati 1 minuman pilihan sesuai syarat voucher.',
      minPurchase: 25000,
      amount: 25000,
      kind: VoucherKind.gratis,
    ),
  ];
}
