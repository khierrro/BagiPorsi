// Data contoh bersama untuk Beranda dan pilihan toko di Chat.
const foodCatalog = [
  FoodListing(
    'Toko Roti Prima',
    'Roti Gandum & Croissant',
    '0.8 km',
    3,
    'Rp 40.000',
    'Gratis',
    'photo-1509440159596-0249088772ff',
    true,
    ['Bakery', 'Sarapan'],
  ),
  FoodListing(
    'Warung Nasi Uduk',
    'Nasi Uduk Komplit',
    '1.2 km',
    2,
    'Rp 20.000',
    'Rp 10.000',
    'photo-1604908176997-125f25cc6f3d',
    false,
    ['Halal', 'Nasi', 'Sarapan', 'Nusantara'],
  ),
  FoodListing(
    'Kebun Segar',
    'Paket Sayuran Segar',
    '0.5 km',
    4,
    'Rp 25.000',
    'Rp 12.000',
    'photo-1540420773420-3366772f4999',
    false,
    ['Sayur & Buah'],
  ),
  FoodListing(
    'Lapak Buah Kita',
    'Paket Buah Campur',
    '1.0 km',
    2,
    'Rp 30.000',
    'Gratis',
    'photo-1619566636858-adf3ef46400b',
    true,
    ['Sayur & Buah'],
  ),
];

class FoodListing {
  const FoodListing(
    this.merchantName,
    this.foodName,
    this.distance,
    this.portionsLeft,
    this.originalPrice,
    this.discountPrice,
    this.photo,
    this.isFree,
    this.categories,
  );

  final String merchantName,
      foodName,
      distance,
      originalPrice,
      discountPrice,
      photo;
  final int portionsLeft;
  final bool isFree;
  final List<String> categories;

  String get imageUrl => photo.startsWith('https://')
      ? photo
      : 'https://images.unsplash.com/$photo?auto=format&fit=crop&w=600&q=80';
}
