import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/data/claim_store.dart';
import 'package:zerohunger/data/food_catalog.dart';
import 'package:zerohunger/data/user_profile_store.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/screens/checkout_makanan.dart';
import 'package:zerohunger/screens/lokasi.dart';

Widget checkoutApp(
  ClaimStore store,
  UserProfileStore profile, {
  double scale = 1,
  ValueChanged<FoodClaim?>? onResult,
  FoodListing? food,
}) => MaterialApp(
  theme: BagiPorsiTheme.data,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: FilledButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<FoodClaim>(
              MaterialPageRoute(
                builder: (_) => CheckoutMakanan(
                  food: food ?? foodCatalog[1],
                  quantity: 1,
                  claims: store,
                  profile: profile,
                ),
              ),
            );
            onResult?.call(result);
          },
          child: const Text('Mulai checkout'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'Checkout memilih alamat tersimpan dan mencatat alamat yang dipilih',
    (tester) async {
      final store = ClaimStore();
      final profile = UserProfileStore();
      addTearDown(store.dispose);
      addTearDown(profile.dispose);
      final home = profile.savePlace(
        label: 'Rumah',
        address: 'Jalan Rumah 1',
        kind: SavedPlaceKind.home,
      );
      profile.savePlace(label: 'Kampus', address: 'Jalan Kampus 10');
      profile.selectLocation(home.id);
      FoodClaim? result;
      await tester.pumpWidget(
        checkoutApp(store, profile, onResult: (claim) => result = claim),
      );
      await tester.tap(find.text('Mulai checkout'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutMakanan), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Jalan Rumah 1'), findsOneWidget);
      await tester.tap(find.text('Ubah lokasi'));
      await tester.pumpAndSettle();
      expect(find.byType(LokasiPage), findsOneWidget);
      await tester.ensureVisible(find.text('Kampus'));
      await tester.tap(find.text('Kampus'));
      await tester.pumpAndSettle();
      expect(find.byType(LokasiPage), findsNothing);
      expect(find.text('Jalan Kampus 10'), findsOneWidget);
      expect(store.claims, isEmpty);
      await tester.tap(find.text('Konfirmasi klaim'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutMakanan), findsNothing);
      expect(store.active.single.userLocation!.address, 'Jalan Kampus 10');
      expect(result!.code, store.active.single.code);
      profile.selectLocation(home.id);
      expect(store.active.single.userLocation!.address, 'Jalan Kampus 10');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Alamat wajib dipilih dan alamat baru langsung kembali ke checkout',
    (tester) async {
      final store = ClaimStore();
      final profile = UserProfileStore();
      addTearDown(store.dispose);
      addTearDown(profile.dispose);
      await tester.pumpWidget(
        checkoutApp(store, profile, food: foodCatalog.first),
      );
      await tester.tap(find.text('Mulai checkout'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Konfirmasi klaim'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Pilih lokasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah baru'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('place-label-field')),
        'Kos',
      );
      await tester.enterText(
        find.byKey(const ValueKey('place-address-field')),
        'Jalan Kos 5',
      );
      await tester.ensureVisible(find.text('Simpan lokasi'));
      await tester.tap(find.text('Simpan lokasi'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutMakanan), findsOneWidget);
      expect(find.byType(LokasiPage), findsNothing);
      expect(find.text('Jalan Kos 5'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Konfirmasi klaim'),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.text('Konfirmasi klaim'));
      await tester.pumpAndSettle();
      expect(store.active.single.totalLabel, 'Gratis');
      expect(store.active.single.userLocation!.label, 'Kos');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Kembali dari pemilih lokasi tidak membuat klaim', (
    tester,
  ) async {
    final store = ClaimStore();
    final profile = UserProfileStore();
    addTearDown(store.dispose);
    addTearDown(profile.dispose);
    await tester.pumpWidget(checkoutApp(store, profile));
    await tester.tap(find.text('Mulai checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih lokasi'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(profile.savedLocations, isEmpty);
    expect(store.claims, isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mulai checkout'), findsOneWidget);
    expect(store.claims, isEmpty);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'Checkout muat pada $width dengan alamat panjang dan teks besar',
      (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = ClaimStore();
        final profile = UserProfileStore()
          ..updateLocation(
            'Jalan Contoh Panjang Nomor 10, Kelurahan Sukamaju, Kecamatan Coblong, Bandung',
          );
        addTearDown(store.dispose);
        addTearDown(profile.dispose);
        await tester.pumpWidget(checkoutApp(store, profile, scale: 1.6));
        await tester.tap(find.text('Mulai checkout'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Kembali ke detail'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Konfirmasi klaim'));
        await tester.pumpAndSettle();
        expect(store.active.single.userLocation!.label, 'Rumah');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
