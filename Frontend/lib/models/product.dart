import '../utils/currency.dart';

/// Kategori yang produknya **diminum**, sehingga butuh pilihan suhu, ukuran,
/// susu, gula, dan es.
///
/// Kategori lain (mis. `Makanan`) dan seluruh merchandise tidak memakai opsi
/// itu. Daftar ini sengaja dikumpulkan di satu tempat supaya katalog bawaan
/// (`kProductCatalog`) dan data dari REST API memakai aturan yang sama.
const Set<String> kDrinkCategories = {
  'Promo & Combo',
  'Baru!',
  'Coffee',
  'Non Coffee',
};

/// `true` kalau [category] termasuk kategori minuman.
bool isDrinkCategory(String category) => kDrinkCategories.contains(category);

/// Satu produk pada katalog Kopi Kangenan.
class Product {
  final String name;
  final int price;
  final String image;
  final String category;

  /// Deskripsi yang tampil di bawah nama pada halaman detail produk.
  final String description;

  /// Menampilkan badge hijau "New" di kartu produk.
  final bool isNew;

  /// Label promo yang menempel di bawah gambar, mis. "Promo Delivery".
  /// Kosong berarti tidak ada badge.
  final String promoLabel;

  const Product({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description = '',
    this.isNew = false,
    this.promoLabel = '',
  });

  /// Harga dalam format tampilan: `28000` → `"Rp28.000"`.
  String get priceLabel => formatRupiah(price);

  /// `true` kalau produk ini minuman, sehingga halaman detail menampilkan
  /// pilihan Temperature, Size, Milk, Sugar, Ice, Topping, dan Syrup.
  bool get isDrink => isDrinkCategory(category);

  /// Bentuk map untuk [ProductDetailScreen].
  ///
  /// Struktur kuncinya (`name`, `price`, `image`, `description`) dipertahankan
  /// seperti semula; `is_drink` ditambahkan supaya halaman detail tahu opsi
  /// mana yang perlu ditampilkan.
  Map<String, String> toProductMap() => {
    'name': name,
    'price': priceLabel,
    'image': image,
    'description': description,
    'is_drink': isDrink ? 'true' : 'false',
  };
}

/// Katalog produk yang dipakai bersama oleh Beranda dan Menu.
///
/// Satu produk boleh muncul di lebih dari satu kategori (mis. Taro Cloud Latte
/// ada di "Baru!" dan "Coffee"), persis seperti katalog aplikasi aslinya.
const List<Product> kProductCatalog = [
  // --- Promo & Combo --- //
  Product(
    name: 'PaHe 1',
    price: 19000,
    image: 'assets/pahe1.png',
    category: 'Promo & Combo',
    description:
        'Kopi Susu Gula Aren ukuran regular plus air mineral. Pilihan paling '
        'ramah kantong untuk ngopi tiap hari.',
  ),
  Product(
    name: 'PaHe 2',
    price: 27000,
    image: 'assets/pahe2.png',
    category: 'Promo & Combo',
    description:
        'Kopi Susu Gula Aren plus croissant butter panggang. Kenyang, hemat, '
        'dan pas untuk sarapan.',
    promoLabel: 'Promo Delivery',
  ),
  Product(
    name: 'PaHe 3',
    price: 29000,
    image: 'assets/pahe3.png',
    category: 'Promo & Combo',
    description:
        'Dua Kopi Susu Gula Aren untuk ngopi berdua. Jauh lebih hemat '
        'daripada membeli satuan.',
  ),

  // --- Baru! --- //
  Product(
    name: 'Taro Cloud Matcha',
    price: 28000,
    image: 'assets/Taro cloud matcha.png',
    category: 'Baru!',
    description:
        'Matcha Jepang dengan busa taro lembut di atasnya. Manisnya pas dan '
        'pahitnya halus.',
    isNew: true,
  ),
  Product(
    name: 'Taro Milk',
    price: 25000,
    image: 'assets/taro milk.png',
    category: 'Baru!',
    description:
        'Susu segar dengan pasta taro asli. Lembut, creamy, dan tidak terlalu '
        'manis.',
    isNew: true,
  ),
  Product(
    name: 'Taro Cloud Latte',
    price: 28000,
    image: 'assets/taro cloud latte.png',
    category: 'Baru!',
    description:
        'Espresso, susu segar, dan busa taro. Perpaduan kopi dan taro dalam '
        'satu gelas.',
    isNew: true,
  ),
  Product(
    name: 'Taro Cloud Milk Tea',
    price: 25000,
    image: 'assets/taro cloud milktea.png',
    category: 'Baru!',
    description:
        'Teh susu dengan rasa taro dan busa lembut sebagai penutup. Segar '
        'dinikmati dingin.',
    isNew: true,
  ),

  // --- Coffee --- //
  Product(
    name: 'Taro Cloud Latte',
    price: 28000,
    image: 'assets/taro cloud latte.png',
    category: 'Coffee',
    description:
        'Espresso, susu segar, dan busa taro. Perpaduan kopi dan taro dalam '
        'satu gelas.',
  ),

  // --- Non Coffee --- //
  Product(
    name: 'Taro Cloud Matcha',
    price: 28000,
    image: 'assets/Taro cloud matcha.png',
    category: 'Non Coffee',
    description:
        'Matcha Jepang dengan busa taro lembut di atasnya. Manisnya pas dan '
        'pahitnya halus.',
  ),
  Product(
    name: 'Taro Milk',
    price: 25000,
    image: 'assets/taro milk.png',
    category: 'Non Coffee',
    description:
        'Susu segar dengan pasta taro asli. Lembut, creamy, dan tidak terlalu '
        'manis.',
  ),
  Product(
    name: 'Taro Cloud Milk Tea',
    price: 25000,
    image: 'assets/taro cloud milktea.png',
    category: 'Non Coffee',
    description:
        'Teh susu dengan rasa taro dan busa lembut sebagai penutup. Segar '
        'dinikmati dingin.',
  ),

  // --- Makanan --- //
  Product(
    name: 'Triple Cheese Bagel',
    price: 22000,
    image: 'assets/triple cheeze bagel.png',
    category: 'Makanan',
    description:
        'Roti bagel bercita rasa keju dari keju parmesan dengan topping keju '
        'mozzarella dan lelehan keju cheddar.',
  ),
  Product(
    name: 'Beef and Cheese Jalapeno Bagel',
    price: 28000,
    image: 'assets/beef and cheese jalapeno bagel.png',
    category: 'Makanan',
    description:
        'Bagel isi daging sapi cincang dan keju, dengan irisan jalapeno yang '
        'memberi rasa pedas segar.',
  ),
  Product(
    name: 'Double Choco Bagel',
    price: 22000,
    image: 'assets/double choco bagel.png',
    category: 'Makanan',
    description:
        'Bagel dengan lelehan cokelat ganda: dark chocolate di dalam dan choco '
        'glaze di atasnya.',
  ),
];

/// Semua produk pada kategori tertentu.
List<Product> productsByCategory(String category) =>
    kProductCatalog.where((product) => product.category == category).toList();
