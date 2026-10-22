import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import 'detail_makanan.dart';

const _green = BagiPorsiColors.green;
const _ink = BagiPorsiColors.ink;

class ListingMakanan extends StatefulWidget {
  const ListingMakanan({super.key});

  @override
  State<ListingMakanan> createState() => _ListingMakananState();
}

class _ListingMakananState extends State<ListingMakanan> {
  static const _toolbarHeight = 60.0;
  static const _headerGreen = BagiPorsiColors.deepGreen;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _greenAreaKey = GlobalKey();
  final _headerState = ValueNotifier<({double blend, double collapse})>((
    blend: 0,
    collapse: 0,
  ));
  String _selectedCategory = 'Semua';

  double get _searchExtent =>
      76 +
      (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(
        0,
        double.infinity,
      );

  static const _categories = [
    (label: 'Semua', icon: Icons.restaurant_rounded, color: Color(0xFFFFEEE0)),
    (label: 'Halal', icon: Icons.verified_outlined, color: Color(0xFFE3F3E8)),
    (label: 'Bakery', icon: Icons.bakery_dining, color: Color(0xFFFFF0D2)),
    (label: 'Sayur & Buah', icon: Icons.eco_outlined, color: Color(0xFFEDF4D9)),
  ];

  static const _foods = foodCatalog;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateHeaderBlend);
  }

  void _updateHeaderBlend() {
    if (!mounted || !_scrollController.hasClients) return;
    final greenArea = _greenAreaKey.currentContext?.findRenderObject();
    if (greenArea is! RenderBox || !greenArea.hasSize) return;

    // Fade over the last header-height of green content. Measure the laid-out
    // content so wrapping, text scaling and screen width move the boundary too.
    final headerHeight = _toolbarHeight + MediaQuery.paddingOf(context).top;
    final fadeStart = _searchExtent + greenArea.size.height - headerHeight;
    final progress = ((_scrollController.offset - fadeStart) / headerHeight)
        .clamp(0.0, 1.0);
    _headerState.value = (
      blend: Curves.easeInOut.transform(progress),
      collapse: (_scrollController.offset / _searchExtent).clamp(0.0, 1.0),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateHeaderBlend);
    _scrollController.dispose();
    _headerState.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'Semua';
    });
  }

  Future<void> _openSearch() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showSearch<String?>(
      context: context,
      query: _searchController.text,
      delegate: _FoodSearchDelegate(
        foods: _foods
            .where(
              (food) =>
                  _selectedCategory == 'Semua' ||
                  food.categories.contains(_selectedCategory),
            )
            .toList(),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _searchController.text = result);
  }

  void _showActivity({required bool transactions}) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                transactions ? 'Riwayat transaksi' : 'Notifikasi',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              Icon(
                transactions
                    ? Icons.receipt_long_outlined
                    : Icons.notifications_none_rounded,
                color: _green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                transactions
                    ? 'Belum ada riwayat transaksi'
                    : 'Belum ada notifikasi',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _ink, fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final foods = _foods.where((food) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          food.categories.contains(_selectedCategory);
      final matchesQuery = '${food.foodName} ${food.merchantName}'
          .toLowerCase()
          .contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          // Recheck after layout when the viewport or content size changes.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateHeaderBlend();
          });
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            ValueListenableBuilder<({double blend, double collapse})>(
              valueListenable: _headerState,
              builder: (context, state, child) => _buildNavbar(query, state),
            ),
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamatkan makanan hari ini',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${foods.length} pilihan makanan tersedia',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (foods.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    mainAxisExtent:
                        316 +
                        (MediaQuery.textScalerOf(context).scale(14) - 14) * 18,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return FoodCard(
                      merchantName: food.merchantName,
                      foodName: food.foodName,
                      distance: food.distance,
                      portionsLeft: food.portionsLeft,
                      originalPrice: food.originalPrice,
                      discountPrice: food.discountPrice,
                      imageUrl: food.imageUrl,
                      isFree: food.isFree,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(String query, ({double blend, double collapse}) state) {
    final background = Color.lerp(_headerGreen, Colors.white, state.blend)!;
    final foreground = Color.lerp(Colors.white, Colors.black, state.blend)!;
    final darkIcons =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    final compactSearch = state.collapse >= 0.8;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      expandedHeight: _toolbarHeight + _searchExtent,
      leadingWidth: 56,
      titleSpacing: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: compactSearch
              ? IconButton(
                  key: const ValueKey('compact-search'),
                  tooltip: 'Buka pencarian',
                  onPressed: _openSearch,
                  icon: const Icon(Icons.search_rounded, size: 23),
                )
              : const Icon(
                  Icons.volunteer_activism_outlined,
                  key: ValueKey('brand-icon'),
                  size: 25,
                ),
        ),
      ),
      title: const Text(
        'Bagi Porsi',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _showActivity(transactions: false),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Riwayat transaksi',
          onPressed: () => _showActivity(transactions: true),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.paddingOf(context).top + _toolbarHeight + 4,
              left: 18,
              right: 18,
              child: ExcludeSemantics(
                excluding: compactSearch,
                child: IgnorePointer(
                  ignoring: compactSearch,
                  child: Opacity(
                    opacity: 1 - state.collapse,
                    child: SizedBox(
                      height: _searchExtent - 20,
                      child: _buildNavbarSearch(query),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbarSearch(String query) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: _ink, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Cari makanan atau toko...',
        hintStyle: const TextStyle(color: Color(0xFF858D89), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF4B5550)),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close),
                onPressed: () => setState(_searchController.clear),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFB5D7CB)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      key: _greenAreaKey,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 44,
          child: IgnorePointer(
            child: ValueListenableBuilder<({double blend, double collapse})>(
              valueListenable: _headerState,
              builder: (context, state, child) =>
                  _AnimatedHeaderWave(active: state.blend < 1),
            ),
          ),
        ),
        ClipPath(
          clipper: const _HeaderWaveClipper(),
          child: ColoredBox(
            color: _headerGreen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 44),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Porsi baik, harga lebih hemat.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: BagiPorsiColors.lime,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.ramen_dining_rounded,
                        size: 48,
                        color: _headerGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _categories.map((category) {
          final selected = _selectedCategory == category.label;
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selectedCategory = category.label),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 2,
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? _green : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(category.icon, color: _green, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? _green : Colors.black54,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: BagiPorsiColors.mint,
            child: Icon(Icons.search_off_rounded, size: 44, color: _green),
          ),
          const SizedBox(height: 18),
          const Text(
            'Makanan belum ditemukan',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci atau kategori lainnya.',
            textAlign: TextAlign.center,
            style: TextStyle(color: BagiPorsiColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _resetFilters,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
              ),
              child: const Text('Tampilkan semua makanan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedHeaderWave extends StatefulWidget {
  const _AnimatedHeaderWave({required this.active});

  final bool active;

  @override
  State<_AnimatedHeaderWave> createState() => _AnimatedHeaderWaveState();
}

class _AnimatedHeaderWaveState extends State<_AnimatedHeaderWave>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePlayback();
  }

  @override
  void didUpdateWidget(_AnimatedHeaderWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _updatePlayback();
  }

  void _updatePlayback() {
    final shouldAnimate =
        widget.active &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _HeaderWavePainter(_controller)),
  );
}

class _HeaderWavePainter extends CustomPainter {
  _HeaderWavePainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = animation.value * 2 * math.pi;
    // Both layers close the same loop, avoiding a jump when playback repeats.
    _paintLayer(canvas, size, phase, 0.82, 0.10, const Color(0xFFC2E9D4));
    _paintLayer(
      canvas,
      size,
      -phase + 0.8,
      0.67,
      0.15,
      const Color(0xFF8ED1AD),
    );
  }

  void _paintLayer(
    Canvas canvas,
    Size size,
    double phase,
    double baseline,
    double amplitude,
    Color color,
  ) {
    final path = Path()..lineTo(size.width, 0);
    for (var step = 64; step >= 0; step--) {
      final fraction = step / 64;
      path.lineTo(
        size.width * fraction,
        size.height *
            (baseline + math.sin(fraction * 2 * math.pi + phase) * amplitude),
      );
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HeaderWavePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  const _HeaderWaveClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 16)
    ..quadraticBezierTo(
      size.width * 0.20,
      size.height + 8,
      size.width * 0.50,
      size.height - 16,
    )
    ..quadraticBezierTo(
      size.width * 0.78,
      size.height - 40,
      size.width,
      size.height - 20,
    )
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(_HeaderWaveClipper oldClipper) => false;
}

class _FoodSearchDelegate extends SearchDelegate<String?> {
  _FoodSearchDelegate({required this.foods})
    : super(searchFieldLabel: 'Cari makanan atau toko...');

  final List<FoodListing> foods;

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Kembali',
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Hapus pencarian',
        icon: const Icon(Icons.close),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildSuggestions(BuildContext context) => _buildMatches(context);

  @override
  Widget buildResults(BuildContext context) => _buildMatches(context);

  Widget _buildMatches(BuildContext context) {
    final keyword = query.trim().toLowerCase();
    final matches = foods
        .where(
          (food) => '${food.foodName} ${food.merchantName}'
              .toLowerCase()
              .contains(keyword),
        )
        .toList();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${matches.length} pilihan makanan tersedia',
                style: const TextStyle(color: BagiPorsiColors.muted),
              ),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Makanan belum ditemukan',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final food = matches[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        leading: const Icon(
                          Icons.restaurant_rounded,
                          color: _green,
                        ),
                        title: Text(food.foodName),
                        subtitle: Text(food.merchantName),
                        trailing: const Icon(
                          Icons.north_west_rounded,
                          size: 20,
                        ),
                        onTap: () => close(context, food.foodName),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => close(context, query),
                child: const Text('Tampilkan hasil di Beranda'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String merchantName,
      foodName,
      distance,
      originalPrice,
      discountPrice,
      imageUrl;
  final int portionsLeft;
  final bool isFree;

  const FoodCard({
    super.key,
    required this.merchantName,
    required this.foodName,
    required this.distance,
    required this.portionsLeft,
    required this.originalPrice,
    required this.discountPrice,
    required this.imageUrl,
    required this.isFree,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BagiPorsiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 116,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 116,
                  width: double.infinity,
                  color: const Color(0xFFEDF3EB),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: _green,
                    semanticLabel: 'Gambar makanan tidak tersedia',
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFree ? _green : const Color(0xFFFFE3BA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFree ? 'Gratis' : 'Harga hemat',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isFree ? Colors.white : const Color(0xFF7C4600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    merchantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Text(
                        'Sisa $portionsLeft',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB65F19),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    originalPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    discountPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: portionsLeft <= 0
                          ? null
                          : () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => DetailMakanan(
                                  merchantName: merchantName,
                                  foodName: foodName,
                                  distance: distance,
                                  portionsLeft: portionsLeft,
                                  originalPrice: originalPrice,
                                  discountPrice: discountPrice,
                                  imageUrl: imageUrl,
                                  isFree: isFree,
                                ),
                              ),
                            ),
                      child: const Text(
                        'Ambil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
