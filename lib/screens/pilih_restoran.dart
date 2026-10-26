import 'package:flutter/material.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';
import 'chat_penjual.dart';

class PilihRestoran extends StatefulWidget {
  const PilihRestoran({super.key, required this.store});
  final ChatStore store;
  @override
  State<PilihRestoran> createState() => _PilihRestoranState();
}

class _PilihRestoranState extends State<PilihRestoran> {
  final _searchController = TextEditingController();
  bool _completed = false;
  static final _restaurants = {
    for (final food in foodCatalog) food.merchantName: food,
  }.values.toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, child) {
      final query = _searchController.text.trim().toLowerCase();
      final restaurants = _restaurants.where((restaurant) {
        return widget.store.isCompleted(restaurant.merchantName) ==
                _completed &&
            foodCatalog.any(
              (food) =>
                  food.merchantName == restaurant.merchantName &&
                  '${food.merchantName} ${food.foodName}'
                      .toLowerCase()
                      .contains(query),
            );
      }).toList();
      restaurants.sort((a, b) {
        final aMessages = widget.store.messagesFor(a.merchantName);
        final bMessages = widget.store.messagesFor(b.merchantName);
        if (aMessages.isNotEmpty && bMessages.isNotEmpty) {
          return bMessages.last.createdAt.compareTo(aMessages.last.createdAt);
        }
        return (bMessages.isNotEmpty ? 1 : 0).compareTo(
          aMessages.isNotEmpty ? 1 : 0,
        );
      });

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: BagiPorsiColors.ink,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Pesan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Tentang percakapan',
              onPressed: () => showFeatureSheet(
                context,
                title: 'Obrolan untuk porsi baik',
                icon: Icons.chat_bubble_outline_rounded,
                message: 'Tanyakan stok, alamat, dan jadwal pengambilan kepada toko. Pesan saat ini tersimpan di sesi perangkat ini dan belum dikirim ke toko.',
              ),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BagiPorsiColors.border),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.forum_outlined,
                        color: BagiPorsiColors.green,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Obrolan kecil, dampak baik.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: BagiPorsiColors.ink,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Pastikan porsi dan atur pengambilan dengan toko.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: BagiPorsiColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari restoran atau makanan...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BagiPorsiColors.green,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian restoran',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_searchController.clear),
                        ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: BagiPorsiColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BagiPorsiColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _tab('Aktif', false)),
                    Expanded(child: _tab('Selesai', true)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _completed ? 'Percakapan selesai' : 'Pilih restoran',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${restaurants.length} restoran tersedia',
                style: const TextStyle(
                  color: BagiPorsiColors.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              if (restaurants.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: BagiPorsiColors.mint,
                        child: Icon(
                          _completed
                              ? Icons.task_alt_rounded
                              : Icons.search_off_rounded,
                          color: BagiPorsiColors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _completed && query.isEmpty
                            ? 'Belum ada percakapan selesai'
                            : 'Restoran belum ditemukan',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _completed && query.isEmpty
                            ? 'Percakapan yang kamu tandai selesai akan muncul di sini.'
                            : 'Coba nama restoran atau makanan lainnya.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              for (final restaurant in restaurants)
                _buildRestaurant(restaurant),
            ],
          ),
        ),
      );
    },
  );

  Widget _tab(String title, bool completed) => Material(
    color: Colors.transparent,
    shape: Border(
      bottom: BorderSide(
        color: _completed == completed
            ? BagiPorsiColors.green
            : Colors.transparent,
        width: 2,
      ),
    ),
    child: InkWell(
      onTap: () => setState(() => _completed = completed),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _completed == completed
                ? BagiPorsiColors.green
                : BagiPorsiColors.muted,
          ),
        ),
      ),
    ),
  );

  Widget _buildRestaurant(FoodListing restaurant) {
    final draft = widget.store.draftFor(restaurant.merchantName);
    final messages = widget.store.messagesFor(restaurant.merchantName);
    final preview = draft.isNotEmpty
        ? 'Draf: $draft'
        : messages.isNotEmpty
        ? 'Belum terkirim: ${messages.last.text}'
        : restaurant.foodName;
    final time = messages.isEmpty
        ? null
        : TimeOfDay.fromDateTime(messages.last.createdAt).format(context);
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.white,
        shape: const Border(bottom: BorderSide(color: BagiPorsiColors.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) =>
                    ChatPenjual(restaurant: restaurant, store: widget.store),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FoodPhoto(food: restaurant, size: 50, radius: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.merchantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: BagiPorsiColors.ink,
                              ),
                            ),
                          ),
                          if (time != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 9,
                                color: BagiPorsiColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: draft.isNotEmpty
                              ? BagiPorsiColors.green
                              : BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          Text(
                            _completed
                                ? 'Selesai'
                                : messages.isNotEmpty
                                ? 'Pesan tersimpan'
                                : 'Tanya ketersediaan',
                            style: const TextStyle(
                              fontSize: 10,
                              color: BagiPorsiColors.green,
                            ),
                          ),
                          Text(
                            '· ${restaurant.distance}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: BagiPorsiColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
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
