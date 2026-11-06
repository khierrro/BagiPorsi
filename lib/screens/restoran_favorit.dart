import 'package:flutter/material.dart';

import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/claim_scope.dart';
import '../widgets/feature_widgets.dart';
import 'listing_makanan.dart';

class RestoranFavoritPage extends StatelessWidget {
  const RestoranFavoritPage({super.key, required this.profile});

  final UserProfileStore profile;

  int _available(BuildContext context, FoodListing food) =>
      ClaimScope.maybeOf(context)?.store.available(food) ?? food.portionsLeft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: const Text(
          'Favorit',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: BagiPorsiColors.ink,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: profile,
        builder: (context, child) {
          final favorites = foodCatalog
              .where((food) => profile.isFavorite(food.merchantName))
              .toList();
          final recommendations = foodCatalog
              .where((food) => !profile.isFavorite(food.merchantName))
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              if (favorites.isEmpty)
                _buildEmptyHero()
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Text(
                    '${favorites.length} tempat tersimpan',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final food in favorites)
                        FoodCard(
                          merchantName: food.merchantName,
                          foodName: food.foodName,
                          distance: food.distance,
                          portionsLeft: food.portionsLeft,
                          originalPrice: food.originalPrice,
                          discountPrice: food.discountPrice,
                          imageUrl: food.imageUrl,
                          isFree: food.isFree,
                          isFavorite: true,
                          onToggleFavorite: () =>
                              profile.toggleFavorite(food.merchantName),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (recommendations.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Text(
                    'Pilihan teratas dari lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < recommendations.length; i++) ...[
                        if (i > 0) const SizedBox(width: 14),
                        _RecommendationCard(
                          food: recommendations[i],
                          remaining: _available(context, recommendations[i]),
                          isFavorite: profile.isFavorite(
                            recommendations[i].merchantName,
                          ),
                          onToggleFavorite: () => profile.toggleFavorite(
                            recommendations[i].merchantName,
                          ),
                          onTap: () =>
                              openFoodDetails(context, recommendations[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        children: [
          const _FavoriteIllustration(),
          const SizedBox(height: 28),
          const Text(
            'Belum ada favorit?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: BagiPorsiColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan lewat rekomendasi di bawah ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: BagiPorsiColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteIllustration extends StatelessWidget {
  const _FavoriteIllustration();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 286,
        height: 196,
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              top: 26,
              child: _IllustrationTile(
                icon: Icons.ramen_dining_rounded,
                iconBg: Color(0xFFFFF3D6),
                iconColor: Color(0xFFE65100),
              ),
            ),
            const Positioned(
              left: 98,
              top: 56,
              child: _IllustrationTile(
                icon: Icons.bakery_dining_rounded,
                iconBg: Color(0xFFE6F4EA),
                iconColor: BagiPorsiColors.green,
              ),
            ),
            const Positioned(
              right: 0,
              top: 0,
              child: _IllustrationTile(
                icon: Icons.location_on_rounded,
                iconBg: Color(0xFFD6ECFF),
                iconColor: Color(0xFF1565C0),
                showMapLines: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationTile extends StatelessWidget {
  const _IllustrationTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.showMapLines = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool showMapLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F5F2),
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (showMapLines)
                const Positioned.fill(
                  child: CustomPaint(painter: _MiniMapLinesPainter()),
                ),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Color(0xFFF4511E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 76,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F5F2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 46,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F5F2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

class _MiniMapLinesPainter extends CustomPainter {
  const _MiniMapLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.55, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.28),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.food,
    required this.remaining,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final FoodListing food;
  final int remaining;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  String get _promoLabel {
    if (food.isFree) return 'Gratis porsi baik';
    return 'Hemat ${food.discountPrice}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BagiPorsiColors.border),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    FoodPhoto(food: food, size: 152, radius: 14),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: food.isFree
                              ? BagiPorsiColors.green
                              : BagiPorsiColors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          food.isFree ? 'Gratis' : 'Hemat',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        child: SizedBox(
                          width: 32,
                          height: 32,
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
                              size: 18,
                              color: isFavorite
                                  ? const Color(0xFFE53935)
                                  : BagiPorsiColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  food.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: BagiPorsiColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food.merchantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BagiPorsiColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: BagiPorsiColors.muted,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        food.distance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                    ),
                    const Text(
                      ' · ',
                      style: TextStyle(
                        fontSize: 11,
                        color: BagiPorsiColors.muted,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Sisa $remaining porsi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: BagiPorsiColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_rounded,
                        size: 12,
                        color: BagiPorsiColors.orange,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _promoLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BagiPorsiColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
