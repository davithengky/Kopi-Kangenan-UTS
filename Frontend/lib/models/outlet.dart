/// Outlet tempat pesanan dibuat.
class Outlet {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  /// Jarak tampilan, mis. "1,2 km".
  final String distance;

  const Outlet({
    required this.name,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.distance = '',
  });
}

/// Semua outlet yang bisa dipilih (PRD F7).
const List<Outlet> kOutlets = [
  Outlet(
    name: 'Tunjungan Plaza 3',
    address: 'Tunjungan Plaza 3, Lantai 5, Surabaya',
    latitude: -7.2626,
    longitude: 112.7382,
    distance: '1,2 km',
  ),
  Outlet(
    name: 'Ketintang UNESA',
    address: 'Jl. Ketintang No. 12, Surabaya',
    latitude: -7.3117,
    longitude: 112.7276,
    distance: '3,4 km',
  ),
  Outlet(
    name: 'Darmo Trade Center',
    address: 'Darmo Trade Center, Lantai UG, Surabaya',
    latitude: -7.2899,
    longitude: 112.7364,
    distance: '4,1 km',
  ),
];

/// Outlet yang sedang dipilih secara default.
const Outlet kDefaultOutlet = Outlet(
  name: 'Tunjungan Plaza 3',
  address: 'Tunjungan Plaza 3, Lantai 5, Surabaya',
  latitude: -7.2626,
  longitude: 112.7382,
  distance: '1,2 km',
);

/// Mode pengambilan pesanan (PRD F7).
enum FulfilmentMode {
  delivery('Delivery'),
  pickup('Pickup');

  const FulfilmentMode(this.label);

  final String label;
}
