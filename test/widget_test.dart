import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zerohunger/main.dart';
import 'package:zerohunger/screens/pilih_restoran.dart';
import 'package:zerohunger/screens/listing_makanan.dart';
import 'package:zerohunger/screens/peta.dart';
import 'package:zerohunger/screens/profil.dart';

void main() {
  setUp(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('Beranda tampil saat aplikasi dibuka', (tester) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListingMakanan), findsOneWidget);
    expect(find.text('Porsi baik, harga lebih hemat.'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    // Widget tests return HTTP 400, exercising the offline image fallback.
    expect(find.byIcon(Icons.broken_image_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Navigasi membuka halaman yang dipilih', (tester) async {
    await tester.pumpWidget(const BagiPorsiApp());

    await tester.tap(find.text('Peta'));
    await tester.pumpAndSettle();
    expect(find.byType(Peta), findsOneWidget);
    expect(find.text('Peta Restoran'), findsNothing);
    expect(find.text('AREA PENCARIAN'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.byType(PilihRestoran), findsOneWidget);
    expect(find.text('Pesan'), findsNothing);
    expect(find.text('Pilih restoran'), findsOneWidget);
    expect(find.text('Ketik pesan...'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(Profil), findsOneWidget);
    expect(find.text('Profil Saya'), findsNothing);
    expect(find.text('Pejuang Pangan'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.byType(ListingMakanan), findsOneWidget);
  });
}
