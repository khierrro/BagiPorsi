import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/main.dart';
import 'package:zerohunger/screens/listing_makanan.dart';

List<String> foodNames(WidgetTester tester) => tester
    .widgetList<FoodCard>(find.byType(FoodCard))
    .map((card) => card.foodName)
    .toList();

Future<void> showResults(WidgetTester tester) async {
  final heading = find.text('Selamatkan makanan hari ini');
  await tester.scrollUntilVisible(
    heading,
    150,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(heading);
  await tester.pumpAndSettle();
}

Future<void> showSearch(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
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

  testWidgets(
    'Gelombang bergerak tanpa menggeser konten dan berhenti di luar layar',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: false);
      await tester.pumpWidget(const BagiPorsiApp());
      await tester.pump(const Duration(milliseconds: 200));
      final hero = find.byType(SliverToBoxAdapter).first;
      final wave = find.descendant(
        of: hero,
        matching: find.byType(RepaintBoundary),
      );
      final boundary = tester.renderObject<RenderRepaintBoundary>(wave);
      final initialText = tester.getRect(
        find.text('Selamatkan porsi, jaga bumi kita.'),
      );
      final greenContent = find.descendant(
        of: hero,
        matching: find.byType(ClipPath),
      );
      final initialHero = tester.getRect(greenContent);
      Future<List<int>?> pixels() => tester.runAsync(() async {
        final frame = await boundary.toImage();
        try {
          return (await frame.toByteData())!.buffer.asUint8List().toList();
        } finally {
          frame.dispose();
        }
      });
      final firstFrame = await pixels();
      await tester.pump(const Duration(milliseconds: 750));
      expect(await pixels(), isNot(orderedEquals(firstFrame!)));
      expect(
        tester.getRect(find.text('Selamatkan porsi, jaga bumi kita.')),
        initialText,
      );
      expect(tester.getRect(greenContent), initialHero);

      final controller = tester
          .widget<CustomScrollView>(find.byType(CustomScrollView))
          .controller!;
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      controller.jumpTo(0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      // Device reduced-motion preferences stop the loop while it stays visible.
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('Header tetap dan warna mengikuti scroll pada lebar $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(top: 28);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(const BagiPorsiApp());
      await tester.pumpAndSettle();
      AppBar header() => tester.widget<AppBar>(find.byType(AppBar));
      final title = find.text('Bagi Porsi');
      final initialTitleRect = tester.getRect(title);
      final initialHeaderRect = tester.getRect(find.byType(AppBar));
      final pinnedHeight = initialHeaderRect.height;
      final scrollView = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      final controller = scrollView.controller!;
      final hero = find.descendant(
        of: find.byType(SliverToBoxAdapter).first,
        matching: find.byType(ClipPath),
      );
      final heroHeight = tester.getSize(hero).height;
      expect(tester.getSize(hero).width, width);

      expect(header().backgroundColor, BagiPorsiColors.deepGreen);
      expect(header().foregroundColor, Colors.white);
      expect(
        header().systemOverlayStyle!.statusBarIconBrightness,
        Brightness.light,
      );
      expect(initialTitleRect.top, greaterThanOrEqualTo(28));

      // The real hero and safe header sizes define the transition boundary.
      controller.jumpTo(heroHeight / 2);
      await tester.pump();
      final halfwayColor = header().backgroundColor;
      expect(halfwayColor, isNot(BagiPorsiColors.deepGreen));
      expect(halfwayColor, isNot(Colors.white));
      expect(tester.getRect(title), initialTitleRect);
      expect(tester.getSize(find.byType(AppBar)).height, pinnedHeight);

      controller.jumpTo(heroHeight + 1);
      await tester.pumpAndSettle();
      expect(header().backgroundColor, Colors.white);
      expect(header().foregroundColor, Colors.black);
      expect(header().surfaceTintColor, Colors.transparent);
      expect(header().scrolledUnderElevation, 0);
      expect(
        header().systemOverlayStyle!.statusBarIconBrightness,
        Brightness.dark,
      );
      expect(tester.getRect(title), initialTitleRect);
      expect(find.byTooltip('Buka pencarian'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);

      controller.jumpTo(heroHeight / 2);
      await tester.pump();
      expect(header().backgroundColor, halfwayColor);
      controller.jumpTo(0);
      await tester.pumpAndSettle();
      expect(header().backgroundColor, BagiPorsiColors.deepGreen);
      expect(header().foregroundColor, Colors.white);
      expect(tester.getRect(title), initialTitleRect);
      expect(tester.getRect(find.byType(AppBar)), initialHeaderRect);
      expect(find.byTooltip('Buka pencarian'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Search bar tunggal tetap aktif dan tombol filter berfungsi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Buka pencarian'), findsNothing);

    await showResults(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Buka pencarian'), findsNothing);

    await Scrollable.ensureVisible(
      tester.element(find.text('Urutkan')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Urutkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terdekat'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester).first, 'Paket Sayuran Segar');

    await Scrollable.ensureVisible(
      tester.element(find.text('Preferensi')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preferensi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Porsi gratis'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Roti Gandum & Croissant', 'Paket Buah Campur']);

    await Scrollable.ensureVisible(
      tester.element(find.text('Reset')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notifikasi dari header Beranda dapat dibuka', (tester) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada notifikasi'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(ListingMakanan), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Pencarian menyaring nama makanan dan toko tanpa membedakan huruf',
    (tester) async {
      await tester.pumpWidget(const BagiPorsiApp());
      await tester.enterText(find.byType(TextField), '  CROISSANT  ');
      await tester.pumpAndSettle();
      await showResults(tester);
      expect(foodNames(tester), ['Roti Gandum & Croissant']);

      await showSearch(tester);
      await tester.enterText(find.byType(TextField), 'warung');
      await tester.pumpAndSettle();
      await showResults(tester);
      expect(foodNames(tester), ['Nasi Uduk Komplit']);

      await showSearch(tester);
      await tester.tap(find.byTooltip('Hapus pencarian'));
      await tester.pumpAndSettle();
      await showResults(tester);
      expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Kategori dan pencarian bekerja bersama serta dapat direset', (
    tester,
  ) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.ensureVisible(find.text('Bakery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bakery'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Roti Gandum & Croissant']);

    await showSearch(tester);
    await tester.ensureVisible(find.text('Nasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nasi'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Nasi Uduk Komplit']);

    await showSearch(tester);
    await tester.ensureVisible(find.text('Sayur & Buah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sayur & Buah'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Paket Sayuran Segar', 'Paket Buah Campur']);

    await showSearch(tester);
    await tester.enterText(find.byType(TextField), 'buah');
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Paket Buah Campur']);

    await showSearch(tester);
    await tester.enterText(find.byType(TextField), 'tidak tersedia');
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(find.text('Makanan belum ditemukan'), findsOneWidget);
    expect(find.byType(FoodCard), findsNothing);

    await tester.ensureVisible(find.text('Tampilkan semua makanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tampilkan semua makanan'));
    await tester.pumpAndSettle();
    await showSearch(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await showResults(tester);
    expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('Daftar makanan dengan garis pemisah muat pada lebar $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BagiPorsiApp());
      await tester.pumpAndSettle();
      final categoryY = tester.getTopLeft(find.text('Semua')).dy;
      for (final category in ['Ayam', 'Nasi', 'Sarapan', 'Bakso & Soto']) {
        expect(tester.getTopLeft(find.text(category)).dy, categoryY);
      }
      expect(tester.getTopLeft(find.text('Bakery')).dy, categoryY);
      final categories = find.byKey(const ValueKey('food-category-scroll'));
      await tester.ensureVisible(categories);
      await tester.pumpAndSettle();
      final initialMinumanX = tester.getCenter(find.text('Minuman')).dx;
      await tester.drag(categories, const Offset(-650, 0));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('Minuman')).dx,
        lessThan(initialMinumanX),
      );
      await tester.tap(find.text('Minuman'));
      await tester.pumpAndSettle();
      expect(find.text('0 pilihan makanan tersedia'), findsOneWidget);
      await tester.ensureVisible(find.text('Semua'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Semua'));
      await tester.pumpAndSettle();
      await showResults(tester);
      final cards = find.byType(FoodCard);
      final first = tester.getRect(cards.at(0));
      final second = tester.getRect(cards.at(1));
      expect(second.top, greaterThanOrEqualTo(first.bottom));
      expect(second.left, first.left);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Daftar tetap muat saat ukuran teks diperbesar', (tester) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 1000),
            textScaler: TextScaler.linear(1.6),
            disableAnimations: true,
          ),
          child: const ListingMakanan(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
