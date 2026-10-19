/// Satu baris item di keranjang belanja.
///
/// Dipindahkan dari `providers/cart_store.dart` ke `models/` supaya
/// `models/order.dart` bisa memakainya tanpa membuat lingkaran impor.
/// `providers/cart_store.dart` tetap mengekspor kelas ini, sehingga layar lama
/// yang `import '../../providers/cart_store.dart'` tidak perlu diubah.
class CartItem {
  final String name;
  final String image;
  final int basePrice;
  final int quantity;
  final String size;
  final String milk;
  final String sugar;
  final String ice;
  final List<String> toppings;
  final List<String> syrups;
  final int unitPrice;

  /// Catatan tambahan dari pembeli, mis. "Ga perlu baper".
  final String note;

  const CartItem({
    required this.name,
    required this.image,
    required this.basePrice,
    required this.quantity,
    required this.size,
    required this.milk,
    required this.sugar,
    required this.ice,
    required this.toppings,
    required this.syrups,
    required this.unitPrice,
    this.note = '',
  });

  int get totalPrice => unitPrice * quantity;

  /// `true` kalau item ini punya opsi minuman (ukuran, susu, gula, es).
  ///
  /// Makanan dan merchandise menyimpan nilai kosong, jadi cukup memeriksa
  /// ukurannya. Dipakai halaman detail untuk memutuskan apakah pilihan
  /// Temperature/Size/Milk/Sugar/Ice/Topping/Syrup perlu ditampilkan.
  bool get hasDrinkOptions => size.isNotEmpty;

  /// Ringkasan kustomisasi yang ditampilkan di keranjang dan checkout.
  ///
  /// Nilai kosong dan placeholder `'-'` dibuang, supaya item makanan dan
  /// merchandise tidak memunculkan baris seperti `Standar · · · ·`.
  List<String> get customizationLines => [
    if (size.isNotEmpty) size,
    if (milk.isNotEmpty && milk != '-') milk,
    if (sugar.isNotEmpty && sugar != '-') sugar,
    if (ice.isNotEmpty && ice != '-') ice,
    ...toppings,
    ...syrups,
    if (note.isNotEmpty) note,
  ];

  CartItem copyWith({
    int? quantity,
    String? size,
    String? milk,
    String? sugar,
    String? ice,
    List<String>? toppings,
    List<String>? syrups,
    int? unitPrice,
    String? note,
  }) {
    return CartItem(
      name: name,
      image: image,
      basePrice: basePrice,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      milk: milk ?? this.milk,
      sugar: sugar ?? this.sugar,
      ice: ice ?? this.ice,
      toppings: toppings ?? this.toppings,
      syrups: syrups ?? this.syrups,
      unitPrice: unitPrice ?? this.unitPrice,
      note: note ?? this.note,
    );
  }
}
