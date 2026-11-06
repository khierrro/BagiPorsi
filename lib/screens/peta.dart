import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/claim_scope.dart';
import '../widgets/feature_widgets.dart';
import '../widgets/home_quick_actions.dart';
import 'chat_penjual.dart';
import 'listing_makanan.dart';

class Peta extends StatefulWidget {
  const Peta({super.key, this.profile, this.chatStore});
  final UserProfileStore? profile;
  final ChatStore? chatStore;

  @override
  State<Peta> createState() => _PetaState();
}

class _PetaState extends State<Peta> {
  late final _profile = widget.profile ?? UserProfileStore();
  late final _chatStore = widget.chatStore ?? ChatStore();
  final _search = TextEditingController();
  final _sheet = DraggableScrollableController();
  String _filter = 'Terdekat';
  String? _selectedMerchant;
  static const _positions = [
    Alignment(-.58, -.52),
    Alignment(.44, -.30),
    Alignment(-.40, .06),
    Alignment(.52, .20),
  ];

  static const _filters = [
    ('Terdekat', Icons.near_me_rounded),
    ('Gratis', Icons.volunteer_activism_outlined),
    ('Di bawah Rp15rb', Icons.local_offer_outlined),
    ('Stok terbatas', Icons.bolt_rounded),
  ];

  @override
  void dispose() {
    _search.dispose();
    _sheet.dispose();
    if (widget.profile == null) _profile.dispose();
    if (widget.chatStore == null) _chatStore.dispose();
    super.dispose();
  }

  List<FoodListing> get _foods {
    final query = _search.text.trim().toLowerCase();
    final foods = foodCatalog.where((food) {
      final price =
          int.tryParse(food.discountPrice.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      return '${food.foodName} ${food.merchantName}'.toLowerCase().contains(
            query,
          ) &&
          (_filter != 'Gratis' || food.isFree) &&
          (_filter != 'Di bawah Rp15rb' || price < 15000) &&
          (_filter != 'Stok terbatas' || _available(food) <= 2);
    }).toList();
    foods.sort(
      (a, b) =>
          double.parse(a.distance.split(' ').first)
              .compareTo(double.parse(b.distance.split(' ').first)),
    );
    if (_selectedMerchant != null) {
      final selected = foods.indexWhere(
        (food) => food.merchantName == _selectedMerchant,
      );
      if (selected > 0) foods.insert(0, foods.removeAt(selected));
    }
    return foods;
  }

  int _available(FoodListing food) =>
      ClaimScope.maybeOf(context)?.store.available(food) ?? food.portionsLeft;

  void _select(FoodListing food) {
    setState(() => _selectedMerchant = food.merchantName);
    FocusManager.instance.primaryFocus?.unfocus();
    if (_sheet.isAttached) {
      _sheet.animateTo(
        .52,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _pickupInfo(FoodListing food) {
    showFeatureSheet(
      context,
      title: 'Lokasi pengambilan',
      icon: Icons.directions_walk_rounded,
      message:
          'Pastikan alamat dan waktu pengambilan langsung dengan '
          '${food.merchantName} sebelum berangkat.',
      content: FilledButton.icon(
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Tanyakan alamat ke toko'),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ChatPenjual(restaurant: food, store: _chatStore),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: ListenableBuilder(
      listenable: _profile,
      builder: (context, child) {
        final foods = _foods;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildGrabHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxHeight < 260) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildFilterBar(floating: false),
                          const SizedBox(height: 8),
                          for (final food in foods) _foodCard(food),
                          if (foods.isEmpty) _empty(),
                        ],
                      );
                    }
                    return ClipRect(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: const _NeighborhoodPainter(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: _buildFilterBar(floating: true),
                          ),
                          const Positioned(
                            top: 62,
                            left: 16,
                            child: InfoPill(
                              'Peta ilustrasi · toko contoh',
                              icon: Icons.info_outline,
                              color: Color(0xFF597168),
                              background: Colors.white,
                            ),
                          ),
                          for (final food in foods)
                            Positioned.fill(
                              top: 60,
                              bottom: constraints.maxHeight * .32,
                              child: Align(
                                alignment:
                                    _positions[foodCatalog.indexOf(food)],
                                child: _buildMapMarker(food),
                              ),
                            ),
                          Positioned(
                            right: 16,
                            bottom: constraints.maxHeight * .50,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(
                                side: BorderSide(color: BagiPorsiColors.border),
                              ),
                              elevation: 3,
                              shadowColor: const Color(0x33000000),
                              child: IconButton(
                                tooltip: 'Pusatkan area',
                                onPressed: () =>
                                    setState(() => _selectedMerchant = null),
                                icon: const Icon(
                                  Icons.my_location_rounded,
                                  color: BagiPorsiColors.ink,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          DraggableScrollableSheet(
                            controller: _sheet,
                            initialChildSize: .48,
                            minChildSize: .26,
                            maxChildSize: .88,
                            builder: (context, scrollController) => Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 20,
                                    offset: Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: ListView(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  24,
                                ),
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD5DBD8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Text(
                                        '${foods.length} pilihan untuk diselamatkan',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: BagiPorsiColors.ink,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BagiPorsiColors.mint,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 13,
                                              color: BagiPorsiColors.green,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Self Pick-Up',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: BagiPorsiColors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Tarik ke atas untuk melihat semua makanan · Bebas ongkir',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: BagiPorsiColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (foods.isEmpty) _empty(),
                                  for (final food in foods) _foodCard(food),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildGrabHeader() => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF006B50), Color(0xFF0E8A6A)],
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => chooseUserLocation(context, _profile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0x29FFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AREA PENCARIAN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                                color: Color(0xD9FFFFFF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _profile.location ??
                                        'Pilih area di sekitarmu',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppSearchBar(
              controller: _search,
              hintText: 'Cari makanan atau toko...',
              clearTooltip: 'Hapus pencarian peta',
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() {}),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFilterBar({required bool floating}) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: floating ? 16 : 0, vertical: 4),
    child: Row(
      children: [
        for (final entry in _filters)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: floating
                    ? const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ChoiceChip(
                avatar: Icon(
                  entry.$2,
                  size: 15,
                  color: _filter == entry.$1
                      ? Colors.white
                      : BagiPorsiColors.green,
                ),
                label: Text(entry.$1),
                selected: _filter == entry.$1,
                onSelected: (_) => setState(() {
                  _filter = entry.$1;
                  _selectedMerchant = null;
                }),
                showCheckmark: false,
                selectedColor: BagiPorsiColors.ink,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: _filter == entry.$1
                      ? BagiPorsiColors.ink
                      : BagiPorsiColors.border,
                ),
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: _filter == entry.$1
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: _filter == entry.$1
                      ? Colors.white
                      : BagiPorsiColors.ink,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildMapMarker(FoodListing food) {
    final selected = _selectedMerchant == food.merchantName;
    final badgeColor = food.isFree
        ? BagiPorsiColors.green
        : const Color(0xFFFF8F00);
    return Semantics(
      button: true,
      label: 'Pilih ${food.merchantName}, ${food.discountPrice}',
      child: GestureDetector(
        onTap: () => _select(food),
        child: AnimatedScale(
          scale: selected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? BagiPorsiColors.ink : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? BagiPorsiColors.ink : badgeColor,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x29183C32),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? badgeColor : badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        food.isFree
                            ? Icons.volunteer_activism_rounded
                            : Icons.restaurant_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      food.discountPrice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : BagiPorsiColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(12, 6),
                painter: _PinPointerPainter(
                  color: selected ? BagiPorsiColors.ink : badgeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() => const Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      children: [
        Icon(Icons.search_off, size: 40, color: BagiPorsiColors.green),
        SizedBox(height: 10),
        Text('Belum ada makanan yang cocok', textAlign: TextAlign.center),
        SizedBox(height: 6),
        Text(
          'Coba kata kunci atau filter lainnya.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: BagiPorsiColors.muted),
        ),
      ],
    ),
  );

  Widget _foodCard(FoodListing food) => FoodCard(
    merchantName: food.merchantName,
    foodName: food.foodName,
    distance: food.distance,
    portionsLeft: food.portionsLeft,
    originalPrice: food.originalPrice,
    discountPrice: food.discountPrice,
    imageUrl: food.imageUrl,
    isFree: food.isFree,
    isFavorite: _profile.isFavorite(food.merchantName),
    onToggleFavorite: () => _profile.toggleFavorite(food.merchantName),
    onDirections: () => _pickupInfo(food),
    selected: _selectedMerchant == food.merchantName,
    actionLabel: 'Lihat makanan',
  );
}

class _PinPointerPainter extends CustomPainter {
  const _PinPointerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinPointerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _NeighborhoodPainter extends CustomPainter {
  const _NeighborhoodPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEF2EE),
    );
    final block = Paint()..color = const Color(0xFFE1EAE0);
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 4; col++) {
        final rect = Rect.fromLTWH(
          col * size.width / 4 + 14,
          row * 100.0 + 15,
          size.width / 4 - 24,
          66,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          block,
        );
      }
    }
    final river = Path()
      ..moveTo(size.width * .78, -20)
      ..cubicTo(
        size.width * .42,
        size.height * .32,
        size.width * 1.1,
        size.height * .46,
        size.width * .62,
        size.height,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFC4E3E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28,
    );
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (final x in [.17, .49, .87]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x - 35, size.height),
        road,
      );
    }
    for (final y in [.20, .48, .74]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y + 24),
        road,
      );
    }
    final avenue = Path()
      ..moveTo(-20, size.height * .7)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * .12,
        size.width + 20,
        size.height * .25,
      );
    canvas.drawPath(avenue, road..strokeWidth = 22);

    // Lingkaran radius area pengguna ala GrabMaps
    final center = Offset(size.width * .48, size.height * .34);
    canvas.drawCircle(
      center,
      size.shortestSide * .26,
      Paint()..color = const Color(0x241E88E5),
    );
    canvas.drawCircle(
      center,
      size.shortestSide * .26,
      Paint()
        ..color = const Color(0x551E88E5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(center, 9, Paint()..color = Colors.white);
    canvas.drawCircle(center, 6.5, Paint()..color = const Color(0xFF1E88E5));

    for (final entry in [
      ('Taman kota', Offset(size.width * .06, size.height * .32)),
      ('Area kuliner', Offset(size.width * .38, size.height * .12)),
      ('Ruang hijau', Offset(size.width * .57, size.height * .46)),
    ]) {
      final text = TextPainter(
        text: TextSpan(
          text: entry.$1,
          style: const TextStyle(
            color: Color(0xFF6E8577),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, entry.$2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
