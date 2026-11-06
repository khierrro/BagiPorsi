import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/claim_scope.dart';
import 'detail_makanan.dart';
import 'klaim_saya.dart';

const _green = BagiPorsiColors.green;
const _ink = BagiPorsiColors.ink;

class ListingMakanan extends StatefulWidget {
  const ListingMakanan({super.key, this.profile});

  final UserProfileStore? profile;

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
    'Semua',
    'Ayam',
    'Nasi',
    'Sarapan',
    'Bakso & Soto',
    'Nusantara',
    'Bakery',
    'Sayur & Buah',
    'Jajanan',
    'Minuman',
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
    if (transactions) {
      openClaims(context, history: true);
      return;
    }
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
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: HomeQuickActions(
                profile: widget.profile,
                onOpenHistory: () => _showActivity(transactions: true),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
            SliverToBoxAdapter(child: _buildCategories()),
            if (foods.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.builder(
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

  Widget _buildNavbarSearch(String query) => AppSearchBar(
    controller: _searchController,
    hintText: 'Cari makanan atau toko...',
    clearTooltip: 'Hapus pencarian',
    onChanged: (_) => setState(() {}),
    onClear: () => setState(() {}),
  );
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
            child: Stack(
              children: [
                Positioned(
                  right: 8,
                  top: -14,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Transform.flip(
                        flipX: true,
                        child: const Icon(
                          Icons.volunteer_activism_outlined,
                          size: 160,
                          color: Color(0x1FFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 72, 44),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 68),
                    child: const Align(
                      alignment: Alignment.centerLeft,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryGrid() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Semua kategori makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 92,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 98,
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = _selectedCategory == category;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        Navigator.pop(sheetContext);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? BagiPorsiColors.mint
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? _green
                                    : BagiPorsiColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: _CategoryFoodImage(index: index),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            category,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: selected ? _green : _ink,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kategori makanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Halal'),
                  avatar: const Icon(Icons.verified_outlined, size: 16),
                  selected: _selectedCategory == 'Halal',
                  onSelected: (selected) => setState(
                    () => _selectedCategory = selected ? 'Halal' : 'Semua',
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: BagiPorsiColors.mint,
                  side: const BorderSide(color: BagiPorsiColors.border),
                  shape: const StadiumBorder(),
                  labelStyle: const TextStyle(fontSize: 11, color: _green),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Semua kategori',
                  visualDensity: VisualDensity.compact,
                  onPressed: _showCategoryGrid,
                  icon: const Icon(
                    Icons.grid_view_rounded,
                    size: 19,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            key: const ValueKey('food-category-scroll'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_categories.length, (index) {
                final category = _categories[index];
                final selected = _selectedCategory == category;
                return SizedBox(
                  width: 78,
                  child: Semantics(
                    button: true,
                    selected: selected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 62,
                            height: 62,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? BagiPorsiColors.mint
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? _green : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: _CategoryFoodImage(index: index),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height:
                                MediaQuery.textScalerOf(context).scale(12) *
                                2.6,
                            child: Text(
                              category,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.25,
                                fontSize: 11,
                                color: selected ? _green : _ink,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
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

class _CategoryFoodImage extends StatelessWidget {
  const _CategoryFoodImage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: size * 5,
            maxWidth: size * 5,
            minHeight: size * 2,
            maxHeight: size * 2,
            child: Transform.translate(
              offset: Offset(-(index % 5) * size, -(index ~/ 5) * size),
              child: Image.asset(
                'assets/images/food_categories.png',
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ),
        );
      },
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
    final remaining =
        ClaimScope.maybeOf(context)?.store.available(
          FoodListing(
            merchantName,
            foodName,
            distance,
            portionsLeft,
            originalPrice,
            discountPrice,
            imageUrl,
            isFree,
            const [],
          ),
        ) ??
        portionsLeft;
    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final photoSize = math.min(96.0, constraints.maxWidth * .26);
                return Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: photoSize,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const ColoredBox(
                                                color: Color(0xFFEDF3EB),
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 30,
                                                  color: _green,
                                                  semanticLabel: 'Gambar makanan tidak tersedia',
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFree ? 'Gratis' : 'Harga hemat',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isFree
                                        ? _green
                                        : const Color(0xFF9B5B18),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  foodName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.3,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  merchantName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BagiPorsiColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 12,
                                          color: BagiPorsiColors.muted,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          distance,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: BagiPorsiColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9B5B18),
                                        ),
                                        children: [
                                          const TextSpan(text: 'Sisa '),
                                          TextSpan(
                                            text: '$remaining porsi',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      discountPrice,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: _green,
                                      ),
                                    ),
                                    Text(
                                      originalPrice,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: BagiPorsiColors.muted,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: remaining <= 0
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Ambil',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: BagiPorsiColors.border),
        ],
      ),
    );
  }
}
