import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/data/claim_store.dart';
import 'package:zerohunger/data/food_catalog.dart';

class MemoryStorage implements ClaimStorage {
  String? value;
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async {
    if (gate != null) await gate!.future;
    if (fail) throw StateError('Disk unavailable');
    value = next;
  }
}

void main() {
  test(
    'Alamat klaim tersimpan sebagai snapshot dan data lama tetap bisa dimuat',
    () async {
      final storage = MemoryStorage();
      final store = ClaimStore(storage: storage);
      addTearDown(store.dispose);
      await store.load();
      final legacy = await store.create(foodCatalog.first, 1);
      final claim = await store.create(
        foodCatalog[1],
        1,
        userLocation: const ClaimLocation(
          label: 'Kampus',
          address: 'Jalan Kampus 10',
        ),
      );
      await store.collect(claim.code);
      final restored = ClaimStore(storage: storage);
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.collected.single.userLocation!.label, 'Kampus');
      expect(
        restored.collected.single.userLocation!.address,
        'Jalan Kampus 10',
      );
      expect(restored.active.single.code, legacy.code);
      expect(restored.active.single.userLocation, isNull);
      final oldJson = legacy.toJson()..remove('userLocation');
      expect(FoodClaim.fromJson(oldJson).userLocation, isNull);
    },
  );
  test(
    'Klaim membatasi stok, menghitung total, dan pembatalan melepas stok',
    () async {
      final store = ClaimStore();
      addTearDown(store.dispose);
      final food = foodCatalog[1];
      final claim = await store.create(food, 2);
      expect(claim.total, 20000);
      expect(claim.totalLabel, 'Rp 20.000');
      expect(claim.paymentLabel, 'Tunai saat pengambilan');
      expect(store.activePortions, 2);
      expect(store.available(food), 0);
      expect(() => store.create(food, 1), throwsStateError);
      await store.cancel(claim.code);
      expect(store.active, isEmpty);
      expect(store.history.single.status, ClaimStatus.cancelled);
      expect(store.available(food), 2);
      expect(() => store.collect(claim.code), throwsStateError);
      final free = await store.create(foodCatalog.first, 1);
      expect(free.total, 0);
      expect(free.totalLabel, 'Gratis');
      expect(free.code, isNot(claim.code));
    },
  );

  test('Riwayat dipulihkan; batas waktu kedaluwarsa dan diambil tidak dapat diubah', () async {
    var now = DateTime(2026, 11, 3, 12);
    final storage = MemoryStorage();
    final store = ClaimStore(storage: storage, now: () => now);
    addTearDown(store.dispose);
    await store.load();
    final expired = await store.create(foodCatalog.first, 2);
    final collected = await store.create(foodCatalog[1], 1);
    await store.collect(collected.code);
    now = now.add(const Duration(hours: 2));
    expect(store.statusOf(expired), ClaimStatus.expired);
    expect(() => store.cancel(expired.code), throwsStateError);
    final restored = ClaimStore(storage: storage, now: () => now);
    addTearDown(restored.dispose);
    await restored.load();
    expect(restored.history.length, 2);
    expect(restored.active, isEmpty);
    expect(restored.available(foodCatalog.first), 3);
    expect(restored.available(foodCatalog[1]), 1);
    expect(restored.latest!.code, collected.code);
  });

  test(
    'Klik ganda dan gagal simpan tidak membuat klaim atau mengubah stok',
    () async {
      final storage = MemoryStorage();
      final store = ClaimStore(storage: storage);
      addTearDown(store.dispose);
      await store.load();
      storage.gate = Completer<void>();
      final save = store.create(foodCatalog.first, 1);
      expect(store.busy, isTrue);
      expect(() => store.create(foodCatalog.first, 1), throwsStateError);
      storage.gate!.complete();
      final claim = await save;
      storage.fail = true;
      await expectLater(store.cancel(claim.code), throwsStateError);
      expect(store.active.single.code, claim.code);
      expect(store.available(foodCatalog.first), 2);
      await expectLater(store.create(foodCatalog[1], 1), throwsStateError);
      expect(store.claims.length, 1);
      expect(store.busy, isFalse);
    },
  );

  test('Data rusak tidak ditimpa dan dapat dicoba ulang', () async {
    final storage = MemoryStorage()..value = 'invalid json';
    final store = ClaimStore(storage: storage);
    addTearDown(store.dispose);
    await store.load();
    expect(store.loaded, isFalse);
    expect(store.error, isNotNull);
    expect(() => store.create(foodCatalog.first, 1), throwsStateError);
    expect(storage.value, 'invalid json');
    storage.value = '[]';
    await store.load();
    expect(store.loaded, isTrue);
    expect(store.error, isNull);
  });
}
