/// Satu merchandise pada katalog Kopi Kangenan.
class MerchProduct {
  final String name;
  final int price;
  final String image;
  final String description;

  const MerchProduct({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}

/// Katalog merchandise. Harga disimpan sebagai angka supaya bisa masuk ke
/// keranjang seperti produk minuman.
const List<MerchProduct> kMerchCatalog = [
  MerchProduct(
    name: 'ColorPop Cup',
    price: 109650,
    image: 'assets/merch/ColorPop Cup.png',
    description:
        'Cangkir keramik dengan semburat warna ceria. Tahan panas, cocok untuk '
        'kopi pagi di rumah.',
  ),
  MerchProduct(
    name: 'ColorPop Sip Tumbler',
    price: 177650,
    image: 'assets/merch/ColorPop Sip Tumbler.png',
    description:
        'Tumbler sedotan 600 ml dengan lapisan kaca dalam. Bebas bocor dan '
        'mudah dibawa jalan.',
  ),
  MerchProduct(
    name: 'Capybara',
    price: 49000,
    image: 'assets/merch/Capybara.png',
    description:
        'Boneka maskot capybara Kopi Kangenan. Lembut, tinggi 18 cm, teman '
        'duduk paling tenang.',
  ),
  MerchProduct(
    name: 'Playsonality Bottle',
    price: 199000,
    image: 'assets/merch/Playsonality Bottle.png',
    description:
        'Botol minum stainless 750 ml dengan tutup ulir. Menjaga suhu dingin '
        'hingga 12 jam.',
  ),
  MerchProduct(
    name: 'Playsonality Classic Cup',
    price: 169000,
    image: 'assets/merch/Playsonality  Classic Cup.png',
    description:
        'Cangkir keramik klasik 350 ml dengan garis emas. Elegan untuk '
        'momen santai.',
  ),
  MerchProduct(
    name: 'Playsonality Press Tumbler',
    price: 159000,
    image: 'assets/merch/Playsonality Press Tumbler.png',
    description:
        'Tumbler tekan 500 ml dengan tombol sekali sentuh. Praktis diminum '
        'sambil berkendara.',
  ),
  MerchProduct(
    name: 'Golden Sling Tumbler',
    price: 219000,
    image: 'assets/merch/Golden Sling Tumbler.png',
    description:
        'Tumbler edisi emas 600 ml lengkap dengan tali bahu. Bisa diukir nama.',
  ),
  MerchProduct(
    name: 'ColorPop Bubble Tumbler',
    price: 169150,
    image: 'assets/merch/ColorPop Bubble Tumbler.png',
    description:
        'Tumbler gelembung warna pastel 550 ml. Ringan dan anti pecah.',
  ),
  MerchProduct(
    name: 'Sigma Slim Bottle',
    price: 209000,
    image: 'assets/merch/Sigma Slim Bottle.png',
    description:
        'Botol ramping 500 ml yang muat di kantong tas. Tahan suhu panas '
        'maupun dingin.',
  ),
  MerchProduct(
    name: 'Sigma Sip Cup',
    price: 169000,
    image: 'assets/merch/Sigma Sip Cup.png',
    description: 'Gelas sipping double wall 400 ml untuk kopi susu favoritmu.',
  ),
];

/// Merchandise yang cocok dipakai untuk hasil simulasi "Scan Merchandise".
const MerchProduct kScanMerchSample = MerchProduct(
  name: 'Sigma Slim Bottle',
  price: 209000,
  image: 'assets/merch/Sigma Slim Bottle.png',
  description: 'Botol ramping 500 ml yang muat di kantong tas.',
);
