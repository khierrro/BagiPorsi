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
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
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
        find.text('Porsi baik, harga lebih hemat.'),
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
        tester.getRect(find.text('Porsi baik, harga lebih hemat.')),
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

  for (final width in [320.0, 390.0]) {
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
      final navbar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      final searchExtent = navbar.expandedHeight! - navbar.toolbarHeight;
      final pinnedHeight = initialHeaderRect.height - searchExtent;
      final scrollView = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      final controller = scrollView.controller!;
      final hero = find.descendant(
        of: find.byType(SliverToBoxAdapter).first,
        matching: find.byType(ClipPath),
      );
      final heroHeight = tester.getSize(hero).height;

      expect(header().backgroundColor, BagiPorsiColors.deepGreen);
      expect(header().foregroundColor, Colors.white);
      expect(
        header().systemOverlayStyle!.statusBarIconBrightness,
        Brightness.light,
      );
      expect(initialTitleRect.top, greaterThanOrEqualTo(28));

      // The real hero and safe header sizes define the transition boundary.
      controller.jumpTo(searchExtent + heroHeight - pinnedHeight / 2);
      await tester.pump();
      final halfwayColor = header().backgroundColor;
      expect(halfwayColor, isNot(BagiPorsiColors.deepGreen));
      expect(halfwayColor, isNot(Colors.white));
      expect(tester.getRect(title), initialTitleRect);
      expect(tester.getSize(find.byType(AppBar)).height, pinnedHeight);

      controller.jumpTo(searchExtent + heroHeight + 1);
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
      expect(find.byTooltip('Buka pencarian'), findsOneWidget);

      controller.jumpTo(searchExtent + heroHeight - pinnedHeight / 2);
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

  testWidgets('Ikon pencarian membuka hasil dan menerapkan filter Beranda', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SliverAppBar),
        matching: find.byType(TextField),
      ),
      findsOneWidget,
    );
    expect(find.text('Halo, Pejuang Pangan!'), findsNothing);
    expect(find.text('Temukan porsi baik di sekitarmu.'), findsNothing);
    expect(
      find.text('Kurangi makanan terbuang,\nmulai dari satu porsi.'),
      findsNothing,
    );
    await showResults(tester);
    final scrollPosition = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .offset;
    await tester.tap(find.byTooltip('Buka pencarian'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  WARUNG  ');
    await tester.pumpAndSettle();
    expect(find.text('Nasi Uduk Komplit'), findsOneWidget);
    expect(find.text('Roti Gandum & Croissant'), findsNothing);
    await tester.tap(find.text('Tampilkan hasil di Beranda'));
    await tester.pumpAndSettle();
    expect(foodNames(tester), ['Nasi Uduk Komplit']);
    final controller = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    expect(
      controller.offset,
      scrollPosition.clamp(0, controller.position.maxScrollExtent),
    );

    await tester.tap(find.byTooltip('Buka pencarian'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '  WARUNG  ',
    );
    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
    await tester.tap(find.text('Tampilkan hasil di Beranda'));
    await tester.pumpAndSettle();
    expect(foodNames(tester).length, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notifikasi dan riwayat transaksi dapat dibuka dan ditutup', (
    tester,
  ) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada notifikasi'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Riwayat transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat transaksi'), findsOneWidget);
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
      expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Kategori dan pencarian bekerja bersama serta dapat direset', (
    tester,
  ) async {
    await tester.pumpWidget(const BagiPorsiApp());
    await tester.tap(find.text('Bakery'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Roti Gandum & Croissant']);

    await showSearch(tester);
    await tester.tap(find.text('Halal'));
    await tester.pumpAndSettle();
    await showResults(tester);
    expect(foodNames(tester), ['Nasi Uduk Komplit']);

    await showSearch(tester);
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
    expect(find.text('4 pilihan makanan tersedia'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('Dua kartu per baris tanpa overflow pada lebar $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BagiPorsiApp());
      await tester.pumpAndSettle();
      final categoryY = tester
          .getCenter(find.byIcon(Icons.restaurant_rounded))
          .dy;
      for (final icon in [
        Icons.verified_outlined,
        Icons.bakery_dining,
        Icons.eco_outlined,
      ]) {
        expect(tester.getCenter(find.byIcon(icon)).dy, categoryY);
      }
      await showResults(tester);
      final cards = find.byType(FoodCard);
      final first = tester.getRect(cards.at(0));
      final second = tester.getRect(cards.at(1));
      expect(first.top, second.top);
      expect(second.left, greaterThan(first.right));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Kartu tetap muat saat ukuran teks diperbesar', (tester) async {
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
