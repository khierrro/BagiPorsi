import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/chat_store.dart';
import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/app_search_bar.dart';
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

  void _showConversationInfo() => showFeatureSheet(
    context,
    title: 'Obrolan untuk porsi baik',
    icon: Icons.chat_bubble_outline_rounded,
    message: 'Tanyakan stok, alamat, dan jadwal pengambilan kepada toko. Pesan saat ini tersimpan di sesi perangkat ini dan belum dikirim ke toko.',
  );

  Widget _buildHeader(String query) => DecoratedBox(
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KOTAK MASUK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.9,
                            color: Color(0xD9FFFFFF),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pesan',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: const Color(0x26FFFFFF),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Tentang percakapan',
                    onPressed: _showConversationInfo,
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari restoran atau makanan...',
              clearTooltip: 'Hapus pencarian restoran',
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() {}),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: ListenableBuilder(
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
          backgroundColor: BagiPorsiColors.canvas,
          body: Column(
            children: [
              _buildHeader(query),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: BagiPorsiColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _tab('Aktif', false)),
                          Expanded(child: _tab('Selesai', true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _completed
                                    ? 'Percakapan selesai'
                                    : 'Pilih restoran',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: BagiPorsiColors.ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${restaurants.length} restoran tersedia',
                                style: const TextStyle(
                                  color: BagiPorsiColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (restaurants.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: BagiPorsiColors.border),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: BagiPorsiColors.mint,
                              child: Icon(
                                _completed
                                    ? Icons.task_alt_rounded
                                    : Icons.search_off_rounded,
                                color: BagiPorsiColors.green,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 6),
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
            ],
          ),
        );
      },
    ),
  );

  Widget _tab(String title, bool completed) {
    final selected = _completed == completed;
    return Material(
      color: selected ? BagiPorsiColors.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => setState(() => _completed = completed),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                completed
                    ? Icons.check_circle_outline_rounded
                    : Icons.chat_bubble_outline_rounded,
                size: 14,
                color: selected ? Colors.white : BagiPorsiColors.muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : BagiPorsiColors.muted,
                  ),
                ),
              ),
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
        : restaurant.foodName;
    final time = messages.isEmpty
        ? null
        : TimeOfDay.fromDateTime(messages.last.createdAt).format(context);
    final statusLabel = _completed
        ? 'Selesai'
        : messages.isNotEmpty
        ? 'Pesan tersimpan'
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: messages.isNotEmpty || draft.isNotEmpty
                ? const Color(0xFFB9DFD3)
                : BagiPorsiColors.border,
          ),
        ),
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
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FoodPhoto(food: restaurant, size: 54, radius: 16),
                    if (messages.isNotEmpty || draft.isNotEmpty)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: draft.isNotEmpty
                                ? BagiPorsiColors.orange
                                : BagiPorsiColors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            draft.isNotEmpty
                                ? Icons.edit_rounded
                                : Icons.chat_rounded,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
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
                                fontSize: 15,
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
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: BagiPorsiColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: draft.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: draft.isNotEmpty
                              ? BagiPorsiColors.green
                              : BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (statusLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: BagiPorsiColors.mint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: BagiPorsiColors.green,
                                ),
                              ),
                            ),
                          Text(
                            statusLabel != null
                                ? '· ${restaurant.distance} · ${restaurant.discountPrice}'
                                : '${restaurant.distance} · ${restaurant.discountPrice}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: BagiPorsiColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
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
