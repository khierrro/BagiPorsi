import 'package:flutter/material.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import 'chat_penjual.dart';

class PilihRestoran extends StatefulWidget {
  const PilihRestoran({super.key, required this.store});

  final ChatStore store;

  @override
  State<PilihRestoran> createState() => _PilihRestoranState();
}

class _PilihRestoranState extends State<PilihRestoran> {
  final _searchController = TextEditingController();
  static final _restaurants = {
    for (final food in foodCatalog) food.merchantName: food,
  }.values.toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final restaurants = _restaurants
        .where(
          (restaurant) => foodCatalog.any(
            (food) =>
                food.merchantName == restaurant.merchantName &&
                '${food.merchantName} ${food.foodName}'.toLowerCase().contains(
                  query,
                ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.store,
          builder: (context, child) => ListView(
            padding: const EdgeInsets.all(18),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const Text(
                'Pilih restoran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tanyakan ketersediaan makanan dan waktu pengambilan ke toko pilihanmu.',
                style: TextStyle(color: BagiPorsiColors.muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari restoran atau makanan...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BagiPorsiColors.green,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian restoran',
                          onPressed: () => setState(_searchController.clear),
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: BagiPorsiColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${restaurants.length} restoran tersedia',
                style: const TextStyle(
                  color: BagiPorsiColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              if (restaurants.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: BagiPorsiColors.green,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Restoran belum ditemukan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Coba nama restoran atau makanan lainnya.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              for (final restaurant in restaurants)
                _buildRestaurant(restaurant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurant(FoodListing restaurant) {
    final draft = widget.store.draftFor(restaurant.merchantName);
    final messages = widget.store.messagesFor(restaurant.merchantName);
    final preview = draft.isNotEmpty
        ? 'Draf: $draft'
        : messages.isNotEmpty
        ? 'Belum terkirim: ${messages.last.text}'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: BagiPorsiColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) =>
                    ChatPenjual(restaurant: restaurant, store: widget.store),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: BagiPorsiColors.mint,
                  child: Icon(Icons.storefront, color: BagiPorsiColors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.merchantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        restaurant.foodName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        restaurant.distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BagiPorsiColors.green,
                        ),
                      ),
                      if (preview != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: BagiPorsiColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
