import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/data/chat_store.dart';
import 'package:zerohunger/data/user_profile_store.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/screens/chat_penjual.dart';
import 'package:zerohunger/screens/detail_makanan.dart';
import 'package:zerohunger/screens/peta.dart';
import 'package:zerohunger/screens/pilih_restoran.dart';
import 'package:zerohunger/screens/profil.dart';

Widget app(Widget page, {double textScale = 1}) => MaterialApp(
  theme: BagiPorsiTheme.data,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: true,
    ),
    child: child!,
  ),
  home: page,
);

void main() {
  testWidgets('Peta memfilter katalog, menyimpan favorit, dan membuka detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profile = UserProfileStore();
    addTearDown(profile.dispose);
    await tester.pumpWidget(app(Peta(profile: profile)));
    await tester.pumpAndSettle();
    expect(find.text('4 pilihan untuk diselamatkan'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Gratis'));
    await tester.pumpAndSettle();
    expect(find.text('2 pilihan untuk diselamatkan'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'roti');
    await tester.pumpAndSettle();
    expect(find.text('1 pilihan untuk diselamatkan'), findsOneWidget);
    await tester.drag(
      find.text('1 pilihan untuk diselamatkan'),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Simpan favorit').first);
    await tester.pumpAndSettle();
    expect(profile.isFavorite('Toko Roti Prima'), isTrue);
    await tester.tap(find.text('Lihat makanan').first);
    await tester.pumpAndSettle();
    expect(find.byType(DetailMakanan), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profil mengedit nama, lokasi dan preferensi bersama', (
    tester,
  ) async {
    final profile = UserProfileStore();
    addTearDown(profile.dispose);
    await tester.pumpWidget(app(Profil(profile: profile)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Rani');
    await tester.tap(find.text('Simpan perubahan'));
    await tester.pumpAndSettle();
    expect(profile.name, 'Rani');
    expect(find.text('Rani'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lokasi tersimpan').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lokasi tersimpan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Coblong, Bandung');
    await tester.tap(find.text('Simpan lokasi'));
    await tester.pumpAndSettle();
    expect(profile.location, 'Coblong, Bandung');
    await tester.scrollUntilVisible(
      find.text('Notifikasi').hitTestable(),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(profile.notificationsEnabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Percakapan dapat ditandai selesai dan diaktifkan kembali', (
    tester,
  ) async {
    final store = ChatStore();
    addTearDown(store.dispose);
    store.queueMessage('Toko Roti Prima', 'Tanya stok roti');
    await tester.pumpWidget(app(PilihRestoran(store: store)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Toko Roti Prima'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Toko Roti Prima'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opsi percakapan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tandai selesai'));
    await tester.pumpAndSettle();
    expect(store.isCompleted('Toko Roti Prima'), isTrue);
    await tester.ensureVisible(find.text('Selesai'));
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Toko Roti Prima'));
    await tester.tap(find.text('Toko Roti Prima'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPenjual), findsOneWidget);
    await tester.tap(find.byTooltip('Opsi percakapan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aktifkan kembali'));
    await tester.pumpAndSettle();
    expect(store.isCompleted('Toko Roti Prima'), isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('Peta dan Profil muat pada lebar $width dengan teks besar', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(const Peta(), textScale: 1.6));
      await tester.pumpAndSettle();
      final heading = find.text('4 pilihan untuk diselamatkan');
      if (heading.evaluate().isNotEmpty) {
        await tester.drag(heading, const Offset(0, -350));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(app(const Profil(), textScale: 1.6));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
