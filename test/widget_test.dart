import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zerohunger/main.dart';
import 'package:zerohunger/screens/chat_penjual.dart';
import 'package:zerohunger/screens/listing_makanan.dart';
import 'package:zerohunger/screens/peta.dart';
import 'package:zerohunger/screens/profil.dart';

void main() {
  testWidgets('Beranda tampil saat aplikasi dibuka', (tester) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.pumpAndSettle();

    expect(find.byType(ListingMakanan), findsOneWidget);
    expect(find.text('Halo, Pejuang Pangan!'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    // Widget tests return HTTP 400, exercising the offline image fallback.
    expect(find.byIcon(Icons.broken_image_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Navigasi membuka halaman yang dipilih', (tester) async {
    await tester.pumpWidget(const BagiPorsiApp());

    await tester.tap(find.text('Peta'));
    await tester.pumpAndSettle();
    expect(find.byType(Peta), findsOneWidget);
    expect(find.text('Peta Restoran'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPenjual), findsOneWidget);
    expect(find.text('Ketik pesan...'), findsOneWidget);
    expect(find.byIcon(Icons.storefront), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(Profil), findsOneWidget);
    expect(find.text('Profil Saya'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(find.byType(ListingMakanan), findsOneWidget);
  });
}
