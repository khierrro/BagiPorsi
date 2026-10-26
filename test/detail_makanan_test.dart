import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerohunger/design/bagi_porsi_theme.dart';
import 'package:zerohunger/main.dart';
import 'package:zerohunger/screens/detail_makanan.dart';

void main() {
  setUp(() {
    final dispatcher =
        TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
  });

  for (final selection in [
    (name: 'Roti Gandum & Croissant', merchant: 'Toko Roti Prima', free: true),
    (name: 'Nasi Uduk Komplit', merchant: 'Warung Nasi Uduk', free: false),
  ]) {
    testWidgets('Ambil membuka detail ${selection.name} dan dapat kembali', (
      tester,
    ) async {
      await tester.pumpWidget(const BagiPorsiApp());
      await tester.enterText(find.byType(TextField), selection.name);
      await tester.pumpAndSettle();
      final takeButton = find.widgetWithText(TextButton, 'Ambil');
      await tester.scrollUntilVisible(
        takeButton,
        180,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final scrollOffset = tester
          .widget<CustomScrollView>(find.byType(CustomScrollView))
          .controller!
          .offset;
      await tester.tap(takeButton);
      await tester.pumpAndSettle();

      final detail = tester.widget<DetailMakanan>(find.byType(DetailMakanan));
      expect(detail.foodName, selection.name);
      expect(detail.merchantName, selection.merchant);
      expect(detail.isFree, selection.free);
      expect(find.text(selection.name), findsOneWidget);
      expect(find.text(selection.merchant), findsOneWidget);
      expect(find.text('Detail makanan'), findsOneWidget);
      expect(find.text('Total · 1 porsi'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DetailMakanan), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        selection.name,
      );
      expect(
        tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!
            .offset,
        scrollOffset,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final isFree in [false, true]) {
    testWidgets(
      'Jumlah dibatasi stok dan total dihitung benar, gratis=$isFree',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(_detailApp(isFree: isFree));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Tambah porsi'));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.remove_rounded),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(find.byTooltip('Tambah porsi'));
        await tester.pumpAndSettle();
        expect(find.text('Total · 2 porsi'), findsOneWidget);
        expect(find.text(isFree ? 'Gratis' : 'Rp 20.000'), findsWidgets);
        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.add_rounded),
              )
              .onPressed,
          isNull,
        );

        await tester.tap(find.text('Lanjut ambil'));
        await tester.pumpAndSettle();
        expect(find.text('Ringkasan pengambilan'), findsOneWidget);
        expect(find.text('2 porsi'), findsOneWidget);
        expect(find.text(isFree ? 'Gratis' : 'Rp 20.000'), findsWidgets);
        await tester.tap(find.text('Kembali ke detail'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Kurangi porsi'));
        await tester.pumpAndSettle();
        expect(find.text('Total · 1 porsi'), findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.remove_rounded),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Detail dan ringkasan muat pada layar kecil dengan teks besar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_detailApp(textScale: 1.6));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Tambah porsi'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah porsi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut ambil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Kembali ke detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kembali ke detail'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Porsi habis tidak dapat dilanjutkan', (tester) async {
    await tester.pumpWidget(_detailApp(portionsLeft: 0));
    await tester.pumpAndSettle();
    expect(find.text('Total · 0 porsi'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Porsi habis'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _detailApp({
  bool isFree = false,
  double textScale = 1,
  int portionsLeft = 2,
}) => MaterialApp(
  theme: BagiPorsiTheme.data,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: DetailMakanan(
    merchantName: 'Warung Nasi Uduk',
    foodName: 'Nasi Uduk Komplit',
    distance: '1.2 km',
    portionsLeft: portionsLeft,
    originalPrice: 'Rp 20.000',
    discountPrice: isFree ? 'Gratis' : 'Rp 10.000',
    imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d',
    isFree: isFree,
  ),
);
