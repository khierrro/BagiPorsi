import 'package:flutter/material.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';
import '../widgets/home_quick_actions.dart';
import 'chat_penjual.dart';

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
    Alignment(-.62, -.68),
    Alignment(.46, -.38),
    Alignment(-.44, -.04),
    Alignment(.58, .14),
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
          (_filter != 'Stok terbatas' || food.portionsLeft <= 2);
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

  void _select(FoodListing food) {
    setState(() => _selectedMerchant = food.merchantName);
    FocusManager.instance.primaryFocus?.unfocus();
    if (_sheet.isAttached) {
      _sheet.animateTo(
        .48,
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _profile,
    builder: (context, child) {
      final foods = _foods;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: BagiPorsiColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Peta Restoran',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Atur lokasi',
              onPressed: () => chooseUserLocation(context, _profile),
              icon: const Icon(Icons.location_on_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: InkWell(
                onTap: () => chooseUserLocation(context, _profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: BagiPorsiColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        color: BagiPorsiColors.green,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AREA PENCARIAN',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.3,
                                color: BagiPorsiColors.green,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _profile.location ?? 'Pilih area di sekitarmu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: BagiPorsiColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.expand_more,
                        color: BagiPorsiColors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari makanan atau toko...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BagiPorsiColors.green,
                  ),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian peta',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_search.clear),
                        ),
                  isDense: true,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: BagiPorsiColors.border),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  for (final label in [
                    'Terdekat',
                    'Gratis',
                    'Di bawah Rp15rb',
                    'Stok terbatas',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _filter == label,
                        onSelected: (_) => setState(() {
                          _filter = label;
                          _selectedMerchant = null;
                        }),
                        showCheckmark: false,
                        selectedColor: BagiPorsiColors.green,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _filter == label
                              ? BagiPorsiColors.green
                              : BagiPorsiColors.border,
                        ),
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: _filter == label
                              ? Colors.white
                              : BagiPorsiColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Keep the map and results usable with a keyboard or large text.
                  if (constraints.maxHeight < 260) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final food in foods) _foodCard(food),
                        if (foods.isEmpty) _empty(),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: const _NeighborhoodPainter(),
                        ),
                      ),
                      const Positioned(
                        top: 12,
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
                          bottom: constraints.maxHeight * .30,
                          child: Align(
                            alignment: _positions[foodCatalog.indexOf(food)],
                            child: Semantics(
                              button: true,
                              label:
                                  'Pilih ${food.merchantName}, ${food.discountPrice}',
                              child: GestureDetector(
                                onTap: () => _select(food),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedMerchant == food.merchantName
                                        ? BagiPorsiColors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: BagiPorsiColors.green,
                                      width:
                                          _selectedMerchant == food.merchantName
                                          ? 2
                                          : 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x20183C32),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        food.isFree
                                            ? Icons.volunteer_activism
                                            : Icons.restaurant,
                                        size: 14,
                                        color:
                                            _selectedMerchant ==
                                                food.merchantName
                                            ? Colors.white
                                            : BagiPorsiColors.green,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        food.discountPrice,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              _selectedMerchant ==
                                                  food.merchantName
                                              ? Colors.white
                                              : BagiPorsiColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      DraggableScrollableSheet(
                        controller: _sheet,
                        initialChildSize: .48,
                        minChildSize: .25,
                        maxChildSize: .88,
                        builder: (context, scrollController) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: BagiPorsiColors.border),
                            ),
                          ),
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                            children: [
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: BagiPorsiColors.border,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${foods.length} pilihan untuk diselamatkan',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: BagiPorsiColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tarik ke atas untuk melihat semua makanan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BagiPorsiColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (foods.isEmpty) _empty(),
                              for (final food in foods) _foodCard(food),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );

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

  Widget _foodCard(FoodListing food) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: BagiPorsiColors.border)),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodPhoto(food: food, size: 70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.merchantName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.foodName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${food.distance} · Sisa ${food.portionsLeft} porsi',
                    style: const TextStyle(
                      fontSize: 11,
                      color: BagiPorsiColors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 32,
              child: IconButton(
                tooltip: _profile.isFavorite(food.merchantName)
                    ? 'Hapus favorit'
                    : 'Simpan favorit',
                padding: EdgeInsets.zero,
                onPressed: () => _profile.toggleFavorite(food.merchantName),
                icon: Icon(
                  _profile.isFavorite(food.merchantName)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: BagiPorsiColors.green,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              food.discountPrice,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: BagiPorsiColors.green,
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: [
                IconButton(
                  tooltip: 'Petunjuk pengambilan',
                  onPressed: () => _pickupInfo(food),
                  icon: const Icon(
                    Icons.directions_outlined,
                    color: BagiPorsiColors.green,
                  ),
                ),
                FilledButton(
                  onPressed: () => openFoodDetails(context, food),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Lihat makanan',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _NeighborhoodPainter extends CustomPainter {
  const _NeighborhoodPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF0E9),
    );
    final block = Paint()..color = const Color(0xFFDCE8D8);
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
        ..color = const Color(0xFFBDDFE0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30,
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
    for (final entry in [
      ('Taman kota', Offset(size.width * .06, size.height * .32)),
      ('Area kuliner', Offset(size.width * .38, size.height * .12)),
      ('Ruang hijau', Offset(size.width * .57, size.height * .56)),
    ]) {
      final text = TextPainter(
        text: TextSpan(
          text: entry.$1,
          style: const TextStyle(color: Color(0xFF7D9584), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, entry.$2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
