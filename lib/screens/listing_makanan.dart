import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/claim_store.dart';
import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/claim_scope.dart';
import 'detail_makanan.dart';
import 'klaim_saya.dart';
import 'restoran_favorit.dart';

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

  late final _profile = widget.profile ?? UserProfileStore();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _greenAreaKey = GlobalKey();
  final _headerState = ValueNotifier<({double blend, double collapse})>((
    blend: 0,
    collapse: 0,
  ));
  String _selectedCategory = 'Semua';
  String _selectedPreference = 'Semua';
  String _sortBy = 'Rekomendasi';

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

    final heroHeight = math.max(1.0, greenArea.size.height);
    final progress = (_scrollController.offset / heroHeight).clamp(0.0, 1.0);
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
    if (widget.profile == null) _profile.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'Semua';
      _selectedPreference = 'Semua';
      _sortBy = 'Rekomendasi';
    });
  }

  void _showActivity({required bool transactions}) {
    if (transactions) {
      openClaims(context, history: true);
      return;
    }
    final store = ClaimScope.maybeOf(context)?.store;
    final items = store?.claims ?? const <FoodClaim>[];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (items.isEmpty) ...[
                const SizedBox(height: 28),
                const Icon(
                  Icons.notifications_none_rounded,
                  color: _green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada notifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _ink, fontSize: 16),
                ),
              ] else ...[
                const SizedBox(height: 14),
                for (final claim in items.take(6))
                  Builder(
                    builder: (context) {
                      final status = store!.statusOf(claim);
                      final isActive = status == ClaimStatus.active;
                      final isCollected = status == ClaimStatus.collected;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: BagiPorsiColors.mint,
                          child: Icon(
                            isActive
                                ? Icons.shopping_bag_outlined
                                : isCollected
                                ? Icons.stars_rounded
                                : Icons.info_outline_rounded,
                            color: _green,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isActive
                              ? 'Menunggu diambil · ${claim.food.foodName}'
                              : isCollected
                              ? 'Pengambilan selesai · +${claim.pointsEarned} poin'
                              : 'Klaim dibatalkan · ${claim.food.foodName}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        subtitle: Text(
                          isActive
                              ? 'Kode ${claim.code} di ${claim.food.merchantName} · Ketuk untuk buka Klaim'
                              : '${claim.quantity} porsi dari ${claim.food.merchantName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          openClaims(this.context, history: !isActive);
                        },
                      );
                    },
                  ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
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
      final matchesPreference = switch (_selectedPreference) {
        'Porsi gratis' => food.isFree,
        'Harga hemat' => !food.isFree,
        _ => true,
      };
      final matchesQuery = '${food.foodName} ${food.merchantName}'
          .toLowerCase()
          .contains(query);
      return matchesCategory && matchesPreference && matchesQuery;
    }).toList();
    if (_sortBy == 'Terdekat') {
      foods.sort(
        (a, b) =>
            double.parse(a.distance.split(' ').first)
                .compareTo(double.parse(b.distance.split(' ').first)),
      );
    } else if (_sortBy == 'Stok terbanyak') {
      foods.sort((a, b) => b.portionsLeft.compareTo(a.portionsLeft));
    }

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
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      for (final food in foods)
                        ListenableBuilder(
                          listenable: _profile,
                          builder: (context, child) => FoodCard(
                            merchantName: food.merchantName,
                            foodName: food.foodName,
                            distance: food.distance,
                            portionsLeft: food.portionsLeft,
                            originalPrice: food.originalPrice,
                            discountPrice: food.discountPrice,
                            imageUrl: food.imageUrl,
                            isFree: food.isFree,
                            isFavorite: _profile.isFavorite(food.merchantName),
                            onToggleFavorite: () =>
                                _profile.toggleFavorite(food.merchantName),
                          ),
                        ),
                    ],
                  ),
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
    final subtitleColor = Color.lerp(
      const Color(0xD9FFFFFF),
      BagiPorsiColors.muted,
      state.blend,
    )!;
    final actionCircleColor = Color.lerp(
      const Color(0x24FFFFFF),
      const Color(0xFFF2F4F5),
      state.blend,
    )!;
    final searchFillColor = Color.lerp(
      Colors.white,
      const Color(0xFFF2F4F5),
      state.blend,
    )!;
    final darkIcons =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    final borderColor = Color.lerp(
      Colors.transparent,
      BagiPorsiColors.border,
      state.blend,
    )!;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: borderColor)),
      toolbarHeight: _toolbarHeight,
      collapsedHeight: _toolbarHeight + _searchExtent,
      expandedHeight: _toolbarHeight + _searchExtent,
      leadingWidth: 52,
      titleSpacing: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
      ),
      leading: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(
          Icons.volunteer_activism_outlined,
          key: ValueKey('brand-icon'),
          size: 24,
        ),
      ),
      title: ListenableBuilder(
        listenable: _profile,
        builder: (context, _) => InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => chooseUserLocation(context, _profile),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AMBIL SENDIRI · ${_profile.location ?? "Belum diatur"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: subtitleColor,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                const Text(
                  'Bagi Porsi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (MediaQuery.sizeOf(context).width >= 360) ...[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: actionCircleColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Favorit',
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => RestoranFavoritPage(profile: _profile),
                  ),
                ),
                icon: const Icon(Icons.favorite_border_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: actionCircleColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Notifikasi',
              visualDensity: VisualDensity.compact,
              onPressed: () => _showActivity(transactions: false),
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      flexibleSpace: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.paddingOf(context).top + _toolbarHeight + 2,
              left: 16,
              right: 16,
              child: SizedBox(
                height: _searchExtent - 16,
                child: _buildNavbarSearch(query, searchFillColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbarSearch(String query, Color fillColor) => AppSearchBar(
    controller: _searchController,
    hintText: 'Kamu pesan apa nih?',
    clearTooltip: 'Hapus pencarian',
    fillColor: fillColor,
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
        SizedBox(
          width: double.infinity,
          child: ClipPath(
            clipper: const _HeaderWaveClipper(),
            child: ColoredBox(
              color: _headerGreen,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 68),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selamatkan porsi, jaga bumi kita.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.2,
                          letterSpacing: -0.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kurangi sampah makanan dari setiap porsi yang kamu ambil',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xD9FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      padding: const EdgeInsets.only(bottom: 14),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: _ink,
                    ),
                  ),
                ),
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
          const SizedBox(height: 6),
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
          const SizedBox(height: 12),
          _buildSubCategoryFilterRow(),
        ],
      ),
    );
  }

  void _showPreferenceSheet() {
    const options = ['Semua', 'Porsi gratis', 'Harga hemat'];
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Preferensi makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option == 'Semua' ? 'Semua porsi' : option,
                    style: TextStyle(
                      fontWeight: _selectedPreference == option
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _selectedPreference == option ? _green : _ink,
                    ),
                  ),
                  trailing: _selectedPreference == option
                      ? const Icon(Icons.check_circle_rounded, color: _green)
                      : null,
                  onTap: () {
                    setState(() => _selectedPreference = option);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortSheet() {
    const options = ['Rekomendasi', 'Terdekat', 'Stok terbanyak'];
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Urutkan makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: TextStyle(
                      fontWeight: _sortBy == option
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _sortBy == option ? _green : _ink,
                    ),
                  ),
                  trailing: _sortBy == option
                      ? const Icon(Icons.check_circle_rounded, color: _green)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = option);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryFilterRow() {
    final hasCategory = _selectedCategory != 'Semua';
    final hasPreference = _selectedPreference != 'Semua';
    final hasSort = _sortBy != 'Rekomendasi';
    final hasAnyFilter = hasCategory || hasPreference || hasSort;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (hasCategory) ...[
            _FilterPillButton(
              icon: Icons.ramen_dining_rounded,
              label: 'Kategori: $_selectedCategory',
              hasDropdown: true,
              selected: true,
              onTap: _showCategoryGrid,
            ),
            const SizedBox(width: 8),
          ],
          _FilterPillButton(
            icon: Icons.swap_vert_rounded,
            label: hasSort ? 'Urut: $_sortBy' : 'Urutkan',
            hasDropdown: true,
            selected: hasSort,
            onTap: _showSortSheet,
          ),
          const SizedBox(width: 8),
          _FilterPillButton(
            icon: Icons.restaurant_rounded,
            label: hasPreference ? _selectedPreference : 'Preferensi',
            hasDropdown: true,
            selected: hasPreference,
            onTap: _showPreferenceSheet,
          ),
          if (hasAnyFilter) ...[
            const SizedBox(width: 8),
            _FilterPillButton(
              icon: Icons.restart_alt_rounded,
              label: 'Reset',
              onTap: _resetFilters,
            ),
          ],
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

class _FilterPillButton extends StatelessWidget {
  const _FilterPillButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.hasDropdown = false,
    this.selected = false,
  });

  final IconData icon;
  final String? label;
  final bool hasDropdown;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fgColor = selected ? _green : _ink;
    return Material(
      color: selected ? const Color(0xFFF1F9F5) : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? _green : const Color(0xFFD0D7D4),
          width: selected ? 1.3 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label == null ? 12 : 13,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fgColor),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ],
              if (hasDropdown) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: fgColor,
                ),
              ],
            ],
          ),
        ),
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

class FoodCard extends StatelessWidget {
  final String merchantName,
      foodName,
      distance,
      originalPrice,
      discountPrice,
      imageUrl;
  final int portionsLeft;
  final bool isFree;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDirections;
  final bool selected;
  final String actionLabel;

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
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onDirections,
    this.selected = false,
    this.actionLabel = 'Ambil',
  });

  void _openDetails(BuildContext context) {
    Navigator.of(context).push<void>(
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
          initialIsFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        ),
      ),
    );
  }

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? BagiPorsiColors.mint.withAlpha(110) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? _green : BagiPorsiColors.border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A183C32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: remaining <= 0 ? null : () => _openDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final photoSize = math.min(78.0, constraints.maxWidth * .25);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: photoSize,
                          height: photoSize,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const ColoredBox(
                                          color: Color(0xFFEDF3EB),
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 28,
                                            color: _green,
                                            semanticLabel:
                                                'Gambar makanan tidak tersedia',
                                          ),
                                        ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFree
                                          ? _green
                                          : BagiPorsiColors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isFree ? 'Gratis' : 'Hemat',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.25,
                                  letterSpacing: -0.25,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 5,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFFFB300),
                                  ),
                                  const Text(
                                    '4.8',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  const Text(
                                    '·',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: BagiPorsiColors.muted,
                                    ),
                                  ),
                                  Text(
                                    merchantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: BagiPorsiColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
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
                                      const SizedBox(width: 2),
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
                                        color: _green,
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
                            ],
                          ),
                        ),
                        if (onToggleFavorite != null)
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: IconButton(
                              tooltip: isFavorite
                                  ? 'Hapus favorit'
                                  : 'Simpan favorit',
                              padding: EdgeInsets.zero,
                              onPressed: onToggleFavorite,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? const Color(0xFFE53935)
                                    : BagiPorsiColors.muted,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: BagiPorsiColors.border),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAF9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: BagiPorsiColors.border),
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                const Icon(
                                  Icons.local_offer_rounded,
                                  size: 13,
                                  color: BagiPorsiColors.orange,
                                ),
                                Text(
                                  discountPrice,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
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
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 8,
                            children: [
                              if (onDirections != null)
                                IconButton(
                                  tooltip: 'Petunjuk pengambilan',
                                  onPressed: onDirections,
                                  icon: const Icon(
                                    Icons.directions_outlined,
                                    color: _green,
                                  ),
                                ),
                              TextButton(
                                onPressed: remaining <= 0
                                    ? null
                                    : () => _openDetails(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      BagiPorsiColors.border,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  shape: const StadiumBorder(),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        actionLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
