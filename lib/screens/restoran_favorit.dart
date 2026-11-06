import 'package:flutter/material.dart';

import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';

class RestoranFavoritPage extends StatelessWidget {
  const RestoranFavoritPage({super.key, required this.profile});

  final UserProfileStore profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Restoran favorit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: profile,
        builder: (context, child) {
          final favorites = foodCatalog
              .where((food) => profile.isFavorite(food.merchantName))
              .toList();
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 56,
                      color: BagiPorsiColors.green.withValues(alpha: .4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada restoran favorit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: BagiPorsiColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ketuk ikon hati pada kartu makanan di Peta untuk menyimpannya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BagiPorsiColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final food = favorites[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: FoodPhoto(food: food, size: 48, radius: 12),
                title: Text(
                  food.merchantName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  food.foodName,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  tooltip: 'Hapus favorit',
                  onPressed: () => profile.toggleFavorite(food.merchantName),
                  icon: const Icon(
                    Icons.favorite,
                    color: BagiPorsiColors.green,
                  ),
                ),
                onTap: () => openFoodDetails(context, food),
              );
            },
          );
        },
      ),
    );
  }
}
