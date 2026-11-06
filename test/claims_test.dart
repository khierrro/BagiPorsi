import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zerohunger/data/chat_store.dart';
import 'package:zerohunger/data/claim_store.dart';
import 'package:zerohunger/data/food_catalog.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/screens/detail_makanan.dart';
import 'package:zerohunger/screens/klaim_saya.dart';
import 'package:zerohunger/screens/chat_penjual.dart';
import 'package:zerohunger/widgets/claim_scope.dart';
import 'package:zerohunger/main.dart';

Widget app(ClaimStore store, ChatStore chat, Widget page, {double scale = 1}) =>
    ClaimScope(
      store: store,
      chatStore: chat,
      child: MaterialApp(
        theme: BagiPorsiTheme.data,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: page,
      ),
    );

void main() {
  setUp(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });
  testWidgets(
    'Konfirmasi dari Beranda membuka tab Klaim dengan navigasi utama',
    (tester) async {
      final store = ClaimStore();
      addTearDown(store.dispose);
      await tester.pumpWidget(BagiPorsiApp(claims: store));
      await tester.enterText(find.byType(TextField), 'Nasi Uduk');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(TextButton, 'Ambil').hitTestable(),
        180,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Ambil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut ambil'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Konfirmasi klaim'));
      await tester.tap(find.text('Konfirmasi klaim'));
      await tester.pumpAndSettle();
      expect(store.active.length, 1);
      expect(find.byType(DetailMakanan), findsNothing);
      expect(find.byType(KlaimSaya), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      expect(find.text(store.active.single.code), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Selesaikan pengambilan').hitTestable(),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Selesaikan pengambilan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, sudah diambil'));
      await tester.pumpAndSettle();
      expect(store.active, isEmpty);
      expect(store.collected.length, 1);
      expect(store.points, 10);
      expect(store.rescuedPortions, 1);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('10 poin terkumpul'), findsOneWidget);
      expect(find.text('1 porsi diselamatkan'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  for (final food in foodCatalog) {
    testWidgets(
      'Checkout ${food.foodName} membuat satu kode dan dapat dibatalkan',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = ClaimStore();
        final chat = ChatStore();
        addTearDown(store.dispose);
        addTearDown(chat.dispose);
        await tester.pumpWidget(
          app(
            store,
            chat,
            DetailMakanan(
              merchantName: food.merchantName,
              foodName: food.foodName,
              distance: food.distance,
              portionsLeft: food.portionsLeft,
              originalPrice: food.originalPrice,
              discountPrice: food.discountPrice,
              imageUrl: food.imageUrl,
              isFree: food.isFree,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lanjut ambil'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Konfirmasi klaim'));
        await tester.tap(find.text('Konfirmasi klaim'));
        await tester.pumpAndSettle();
        expect(find.byType(KlaimSaya), findsOneWidget);
        expect(store.claims.length, 1);
        final code = store.active.single.code;
        expect(find.text(code), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Lihat kode $code'));
        await tester.tap(find.byTooltip('Lihat kode $code'));
        await tester.pumpAndSettle();
        expect(find.byType(QrImageView), findsOneWidget);
        expect(find.widgetWithText(SelectableText, code), findsOneWidget);
        await tester.tap(find.byTooltip('Tutup kode'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Batalkan klaim'));
        await tester.tap(find.text('Batalkan klaim'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ya, batalkan'));
        await tester.pumpAndSettle();
        expect(store.active, isEmpty);
        expect(store.available(food), food.portionsLeft);
        await tester.tap(find.text('Riwayat (1)'));
        await tester.pumpAndSettle();
        expect(find.text('Dibatalkan'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('Hubungi penjual membuka draf untuk toko yang sesuai', (
    tester,
  ) async {
    final store = ClaimStore();
    final chat = ChatStore();
    addTearDown(store.dispose);
    addTearDown(chat.dispose);
    final claim = await store.create(foodCatalog[1], 1);
    await tester.pumpWidget(app(store, chat, const KlaimSaya()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Hubungi penjual').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Hubungi penjual'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPenjual), findsOneWidget);
    expect(chat.draftFor(claim.food.merchantName), contains(claim.code));
    expect(chat.messagesFor(claim.food.merchantName), isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('Klaim dan QR muat pada $width dengan teks besar', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = ClaimStore();
      final chat = ChatStore();
      addTearDown(store.dispose);
      addTearDown(chat.dispose);
      final claim = await store.create(foodCatalog.first, 1);
      await tester.pumpWidget(app(store, chat, const KlaimSaya(), scale: 1.6));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Batalkan klaim').hitTestable(),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byTooltip('Lihat kode ${claim.code}'));
      await tester.tap(find.byTooltip('Lihat kode ${claim.code}'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simulasikan pengambilan'));
      await tester.tap(find.text('Simulasikan pengambilan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, sudah diambil'));
      await tester.pumpAndSettle();
      expect(store.active, isEmpty);
      expect(store.history.single.status, ClaimStatus.collected);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
