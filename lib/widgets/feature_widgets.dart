import 'package:flutter/material.dart';

import '../data/food_catalog.dart';
import '../design/bagi_porsi_theme.dart';
import '../screens/detail_makanan.dart';

class FoodPhoto extends StatelessWidget {
  const FoodPhoto({
    super.key,
    required this.food,
    this.size = 64,
    this.radius = 16,
  });
  final FoodListing food;
  final double size, radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox.square(
      dimension: size,
      child: Image.network(
        food.imageUrl,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, error, stack) => const ColoredBox(
          color: BagiPorsiColors.mint,
          child: Icon(Icons.restaurant_rounded, color: BagiPorsiColors.green),
        ),
      ),
    ),
  );
}

class InfoPill extends StatelessWidget {
  const InfoPill(
    this.label, {
    super.key,
    this.icon,
    this.color = BagiPorsiColors.green,
    this.background = BagiPorsiColors.mint,
  });
  final String label;
  final IconData? icon;
  final Color color, background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void openFoodDetails(BuildContext context, FoodListing food) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DetailMakanan(
        merchantName: food.merchantName,
        foodName: food.foodName,
        distance: food.distance,
        portionsLeft: food.portionsLeft,
        originalPrice: food.originalPrice,
        discountPrice: food.discountPrice,
        imageUrl: food.imageUrl,
        isFree: food.isFree,
      ),
    ),
  );
}

Future<void> showFeatureSheet(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  Widget? content,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: Colors.white,
  builder: (context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: BagiPorsiColors.mint,
              child: Icon(icon, color: BagiPorsiColors.green, size: 28),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: BagiPorsiColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: BagiPorsiColors.muted,
            ),
          ),
          if (content != null) ...[const SizedBox(height: 20), content],
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    ),
  ),
);
