import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'food_catalog.dart';

enum ClaimStatus { active, collected, cancelled, expired }

String rupiah(int amount) =>
    'Rp ${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

/// Snapshot of the user's selected address, separate from the pickup store.
class ClaimLocation {
  const ClaimLocation({required this.label, required this.address});
  final String label, address;

  Map<String, dynamic> toJson() => {'label': label, 'address': address};

  factory ClaimLocation.fromJson(Map<String, dynamic> json) {
    final label = json['label'] as String;
    final address = json['address'] as String;
    if (label.trim().isEmpty || address.trim().isEmpty) {
      throw const FormatException('Alamat klaim tidak valid');
    }
    return ClaimLocation(label: label, address: address);
  }
}

class FoodClaim {
  const FoodClaim({
    required this.code,
    required this.food,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
    required this.expiresAt,
    this.status = ClaimStatus.active,
    this.userLocation,
  });

  static const int pointsPerPortion = 10;

  final String code;
  final FoodListing food;
  final int quantity, unitPrice;
  final DateTime createdAt, expiresAt;
  final ClaimStatus status;
  final ClaimLocation? userLocation;
  int get total => unitPrice * quantity;
  String get totalLabel => food.isFree ? 'Gratis' : rupiah(total);
  String get paymentLabel =>
      food.isFree ? 'Tanpa pembayaran' : 'Tunai saat pengambilan';
  int get pointsEarned => quantity * pointsPerPortion;
  int get originalUnitPrice =>
      int.tryParse(food.originalPrice.replaceAll(RegExp(r'[^0-9]'), '')) ??
      unitPrice;
  int get savedAmount => max(0, originalUnitPrice - unitPrice) * quantity;

  FoodClaim withStatus(ClaimStatus value) => FoodClaim(
    code: code,
    food: food,
    quantity: quantity,
    unitPrice: unitPrice,
    createdAt: createdAt,
    expiresAt: expiresAt,
    status: value,
    userLocation: userLocation,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'status': status.name,
    'userLocation': userLocation?.toJson(),
    'food': {
      'merchant': food.merchantName,
      'name': food.foodName,
      'distance': food.distance,
      'stock': food.portionsLeft,
      'originalPrice': food.originalPrice,
      'price': food.discountPrice,
      'photo': food.photo,
      'free': food.isFree,
      'categories': food.categories,
    },
  };

  factory FoodClaim.fromJson(Map<String, dynamic> json) {
    final food = json['food'] as Map<String, dynamic>;
    final claim = FoodClaim(
      code: json['code'] as String,
      food: FoodListing(
        food['merchant'] as String,
        food['name'] as String,
        food['distance'] as String,
        food['stock'] as int,
        food['originalPrice'] as String,
        food['price'] as String,
        food['photo'] as String,
        food['free'] as bool,
        (food['categories'] as List).cast<String>(),
      ),
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: ClaimStatus.values.byName(json['status'] as String),
      userLocation: json['userLocation'] == null
          ? null
          : ClaimLocation.fromJson(
              json['userLocation'] as Map<String, dynamic>,
            ),
    );
    if (claim.quantity < 1 ||
        claim.unitPrice < 0 ||
        claim.quantity > claim.food.portionsLeft ||
        !claim.expiresAt.isAfter(claim.createdAt)) {
      throw const FormatException('Data klaim tidak valid');
    }
    return claim;
  }
}

abstract interface class ClaimStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class DeviceClaimStorage implements ClaimStorage {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'bagiporsi.demo_claims.v1';
  @override
  Future<String?> read() => _preferences.getString(_key);
  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

/// Local demo reservations. A production seller service must validate codes,
/// inventory, pickup windows and payment before these can be real orders.
class ClaimStore extends ChangeNotifier {
  ClaimStore({this.storage, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _loaded = storage == null;

  final ClaimStorage? storage;
  final DateTime Function() _now;
  final _random = Random.secure();
  List<FoodClaim> _claims = [];
  bool _loaded, _busy = false;
  String? _error;
  bool get loaded => _loaded;
  bool get busy => _busy;
  String? get error => _error;
  List<FoodClaim> get claims => List.unmodifiable(_claims);
  List<FoodClaim> get active =>
      claims.where((c) => statusOf(c) == ClaimStatus.active).toList();
  List<FoodClaim> get collected =>
      claims.where((c) => statusOf(c) == ClaimStatus.collected).toList();
  List<FoodClaim> get history =>
      claims.where((c) => statusOf(c) != ClaimStatus.active).toList();
  FoodClaim? get latest => _claims.isEmpty ? null : _claims.first;
  int get activePortions => active.fold(0, (sum, c) => sum + c.quantity);
  int get rescuedPortions => collected.fold(0, (sum, c) => sum + c.quantity);
  int get points => collected.fold(0, (sum, c) => sum + c.pointsEarned);
  int get totalSavings => collected.fold(0, (sum, c) => sum + c.savedAmount);
  String get totalSavingsLabel =>
      totalSavings == 0 ? 'Rp0' : rupiah(totalSavings);
  String get levelTitle {
    if (points >= 100) return 'Pahlawan Zero Hunger';
    if (points >= 30) return 'Penyelamat Porsi';
    return 'Pemula Pangan';
  }

  ClaimStatus statusOf(FoodClaim claim) =>
      claim.status == ClaimStatus.active && !_now().isBefore(claim.expiresAt)
      ? ClaimStatus.expired
      : claim.status;

  int available(FoodListing food) {
    final reserved = _claims
        .where(
          (c) =>
              c.food.merchantName == food.merchantName &&
              c.food.foodName == food.foodName &&
              (statusOf(c) == ClaimStatus.active ||
                  statusOf(c) == ClaimStatus.collected),
        )
        .fold(0, (sum, c) => sum + c.quantity);
    return max(0, food.portionsLeft - reserved);
  }

  Future<void> load() async {
    if (_loaded || _busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await storage?.read();
      final restored = raw == null
          ? <FoodClaim>[]
          : (jsonDecode(raw) as List)
                .map((v) => FoodClaim.fromJson(v as Map<String, dynamic>))
                .toList();
      if (restored.map((c) => c.code).toSet().length != restored.length) {
        throw const FormatException('Kode klaim duplikat');
      }
      _claims = restored;
      _loaded = true;
    } catch (_) {
      _error = 'Riwayat klaim belum bisa dibaca. Coba muat ulang.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<T> _save<T>(List<FoodClaim> next, T result) async {
    _busy = true;
    notifyListeners();
    try {
      await storage?.write(jsonEncode(next.map((c) => c.toJson()).toList()));
      _claims = next;
      return result;
    } catch (_) {
      throw StateError('Klaim belum tersimpan. Coba lagi.');
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _checkReady() {
    if (!_loaded || _busy) throw StateError('Tunggu hingga data klaim siap.');
  }

  Future<FoodClaim> create(
    FoodListing food,
    int quantity, {
    ClaimLocation? userLocation,
  }) {
    _checkReady();
    if (quantity < 1 || quantity > available(food)) {
      throw StateError('Jumlah porsi melebihi stok yang tersedia.');
    }
    if (userLocation != null &&
        (userLocation.label.trim().isEmpty ||
            userLocation.address.trim().isEmpty)) {
      throw StateError('Lokasi pengguna belum lengkap.');
    }
    final price = food.isFree
        ? 0
        : int.tryParse(food.discountPrice.replaceAll(RegExp(r'[^0-9]'), ''));
    if (price == null || (!food.isFree && price <= 0)) {
      throw StateError('Harga makanan belum valid.');
    }
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String code;
    do {
      code =
          'BP-${List.generate(6, (_) => alphabet[_random.nextInt(alphabet.length)]).join()}';
    } while (_claims.any((c) => c.code == code));
    final now = _now();
    final claim = FoodClaim(
      code: code,
      food: food,
      quantity: quantity,
      unitPrice: price,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
      userLocation: userLocation,
    );
    return _save([claim, ..._claims], claim);
  }

  Future<void> cancel(String code) => _transition(code, ClaimStatus.cancelled);
  Future<void> collect(String code) => _transition(code, ClaimStatus.collected);

  Future<void> _transition(String code, ClaimStatus status) {
    _checkReady();
    final index = _claims.indexWhere((c) => c.code == code);
    if (index < 0 || statusOf(_claims[index]) != ClaimStatus.active) {
      throw StateError('Klaim ini sudah tidak aktif.');
    }
    final next = [..._claims];
    next[index] = next[index].withStatus(status);
    return _save<void>(next, null);
  }

  void refreshExpiry() => notifyListeners();
}
