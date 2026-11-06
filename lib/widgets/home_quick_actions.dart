import 'package:flutter/material.dart';

import '../design/bagi_porsi_theme.dart';
import '../data/claim_store.dart';
import '../data/user_profile_store.dart';
import '../screens/lokasi.dart';
import '../screens/profil_pages.dart';
import 'claim_scope.dart';

void showPointsSheet(BuildContext context, ClaimStore? store) {
  Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => PoinKamuPage(store: store)));
}

Future<void> chooseUserLocation(
  BuildContext context,
  UserProfileStore profile,
) async {
  await Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => LokasiPage(profile: profile)));
}

class HomeQuickActions extends StatefulWidget {
  const HomeQuickActions({
    super.key,
    required this.onOpenHistory,
    this.profile,
  });

  final VoidCallback onOpenHistory;
  final UserProfileStore? profile;

  @override
  State<HomeQuickActions> createState() => _HomeQuickActionsState();
}

class _HomeQuickActionsState extends State<HomeQuickActions> {
  late final _profile = widget.profile ?? UserProfileStore();

  @override
  void dispose() {
    if (widget.profile == null) _profile.dispose();
    super.dispose();
  }

  Future<void> _chooseLocation() async {
    await chooseUserLocation(context, _profile);
  }

  void _showPoints() {
    showPointsSheet(context, ClaimScope.maybeOf(context)?.store);
  }

  @override
  Widget build(BuildContext context) {
    final store = ClaimScope.maybeOf(context)?.store;
    final latest = store?.latest;
    final points = store?.points ?? 0;
    final rescued = store?.rescuedPortions ?? 0;
    final extraHeight =
        (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0.0, 28.0) * 3;
    return ListenableBuilder(
      listenable: _profile,
      builder: (context, child) {
        final actions = [
          _QuickAction(
            title: 'Poin kamu',
            value: '$points poin',
            detail: rescued > 0
                ? '$rescued porsi diselamatkan'
                : 'Lihat poin terkumpul',
            icon: Icons.stars_rounded,
            width: 156,
            onTap: _showPoints,
          ),
          _QuickAction(
            title: 'Pembelian terakhir',
            value: latest?.food.foodName ?? 'Belum ada pembelian',
            detail: 'Lihat riwayatmu',
            icon: Icons.receipt_long_outlined,
            width: 208,
            onTap: widget.onOpenHistory,
          ),
          _QuickAction(
            title: 'Lokasi kamu',
            value: _profile.location ?? 'Atur lokasi',
            detail: _profile.savedLocations.isEmpty
                ? 'Pilih area di sekitarmu'
                : '${_profile.savedLocations.length} tempat tersimpan',
            icon: Icons.location_on_outlined,
            width: 208,
            onTap: _chooseLocation,
          ),
        ];
        return SizedBox(
          height: 90 + extraHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return PageView.builder(
                  controller: PageController(viewportFraction: 0.72),
                  padEnds: false,
                  itemCount: actions.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 16 : 6,
                      right: index == actions.length - 1 ? 16 : 6,
                    ),
                    child: actions[index],
                  ),
                );
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  actions[0],
                  const SizedBox(width: 12),
                  actions[1],
                  const SizedBox(width: 12),
                  actions[2],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.width,
    required this.onTap,
  });

  final String title, value, detail;
  final IconData icon;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: BagiPorsiColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: BagiPorsiColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 28, color: BagiPorsiColors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
