import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/data/chat_store.dart';
import 'package:zerohunger/data/food_catalog.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/main.dart';
import 'package:zerohunger/screens/chat_penjual.dart';
import 'package:zerohunger/screens/pilih_restoran.dart';

Future<void> selectRestaurant(WidgetTester tester, String name) async {
  await tester.scrollUntilVisible(
    find.text(name),
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  testWidgets('Chat memilih restoran dari katalog sebelum membuka percakapan', (
    tester,
  ) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.byType(PilihRestoran), findsOneWidget);
    expect(find.byType(ChatPenjual), findsNothing);
    expect(find.text('Ketik pesan...'), findsNothing);
    expect(find.text('Warung Bu Sri'), findsNothing);
    for (final food in foodCatalog) {
      await tester.scrollUntilVisible(
        find.text(food.merchantName),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(food.merchantName), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.byType(TextField),
      -150,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.enterText(find.byType(TextField), '  NASI  ');
    await tester.pumpAndSettle();
    expect(find.text('1 restoran tersedia'), findsOneWidget);
    expect(find.text('Toko Roti Prima'), findsNothing);
    await selectRestaurant(tester, 'Warung Nasi Uduk');
    expect(
      tester
          .widget<ChatPenjual>(find.byType(ChatPenjual))
          .restaurant
          .merchantName,
      'Warung Nasi Uduk',
    );
    expect(find.text('Ketik pesan...'), findsOneWidget);
    expect(find.text('Mulai percakapan'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '  NASI  ',
    );
    await tester.enterText(find.byType(TextField), 'croissant');
    await tester.pumpAndSettle();
    expect(find.text('Toko Roti Prima'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pumpAndSettle();
    expect(find.text('Restoran belum ditemukan'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus pencarian restoran'));
    await tester.pumpAndSettle();
    expect(find.text('4 restoran tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Pesan dan draf terpisah per toko serta bertahan saat pindah tab',
    (tester) async {
      await tester.pumpWidget(const BagiPorsiApp());
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      await selectRestaurant(tester, 'Warung Nasi Uduk');
      await tester.enterText(find.byType(TextField), 'Halo warung');
      await tester.pump();
      await tester.tap(find.byTooltip('Kirim pesan'));
      await tester.pumpAndSettle();
      expect(find.text('Halo warung'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'Draf untuk nasi');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Draf: Draf untuk nasi'), findsOneWidget);

      await selectRestaurant(tester, 'Toko Roti Prima');
      expect(find.text('Halo warung'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'Halo toko roti');
      await tester.pump();
      await tester.tap(find.byTooltip('Kirim pesan'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      await selectRestaurant(tester, 'Warung Nasi Uduk');
      expect(find.text('Halo warung'), findsOneWidget);
      expect(find.text('Halo toko roti'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Draf untuk nasi',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await selectRestaurant(tester, 'Toko Roti Prima');
      expect(find.text('Halo toko roti'), findsOneWidget);
      expect(find.text('Halo warung'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Pesan kosong dicegah dan saran tidak dikirim otomatis', (
    tester,
  ) async {
    final store = ChatStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: BagiPorsiTheme.data,
        home: PilihRestoran(store: store),
      ),
    );
    await selectRestaurant(tester, 'Warung Nasi Uduk');
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.send_rounded),
          )
          .onPressed,
      isNull,
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    expect(store.messagesFor('Warung Nasi Uduk'), isEmpty);

    await tester.tap(find.text('Apakah masih tersedia?'));
    await tester.pumpAndSettle();
    expect(store.messagesFor('Warung Nasi Uduk'), isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Apakah masih tersedia?',
    );
    await tester.tap(find.byTooltip('Kirim pesan'));
    await tester.pumpAndSettle();
    expect(
      store.messagesFor('Warung Nasi Uduk').single.text,
      'Apakah masih tersedia?',
    );
    expect(store.messagesFor('Toko Roti Prima'), isEmpty);
    expect(find.textContaining('Belum terkirim'), findsOneWidget);
    expect(store.draftFor('Warung Nasi Uduk'), isEmpty);
    await tester.enterText(find.byType(TextField), '  Jam berapa?  ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(store.messagesFor('Warung Nasi Uduk').length, 2);
    expect(store.messagesFor('Warung Nasi Uduk').last.text, 'Jam berapa?');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Pilihan restoran dan chat muat dengan teks besar serta keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final store = ChatStore();
      addTearDown(store.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: BagiPorsiTheme.data,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: PilihRestoran(store: store),
        ),
      );
      await tester.enterText(find.byType(TextField), 'nasi');
      await tester.pumpAndSettle();
      await selectRestaurant(tester, 'Warung Nasi Uduk');
      tester.view.viewInsets = FakeViewPadding(bottom: 240);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Halo, saya ingin menanyakan ketersediaan nasi uduk untuk diambil sore ini.',
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Kirim pesan'));
      await tester.pumpAndSettle();
      expect(store.messagesFor('Warung Nasi Uduk').length, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
