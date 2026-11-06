import 'package:flutter/material.dart';

import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';
import 'klaim_saya.dart';
import 'lokasi.dart';
import 'profil_edit.dart';
import 'restoran_favorit.dart';

class Profil extends StatefulWidget {
  const Profil({super.key, this.profile});
  final UserProfileStore? profile;

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  late final _profile = widget.profile ?? UserProfileStore();

  @override
  void dispose() {
    if (widget.profile == null) _profile.dispose();
    super.dispose();
  }

  void _editName() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ProfilEditPage(profile: _profile)),
    );
  }

  void _showFavorites() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => RestoranFavoritPage(profile: _profile)),
    );
  }

  void _editLocation() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => LokasiPage(profile: _profile)),
    );
  }

  void _notificationSettings() {
    showFeatureSheet(
      context,
      title: 'Preferensi notifikasi',
      icon: Icons.notifications_outlined,
      message: 'Atur preferensi pengingat aktivitasmu.',
      content: ListenableBuilder(
        listenable: _profile,
        builder: (context, child) => SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pengingat aktivitas'),
          subtitle: const Text(
            'Simpan preferensi untuk pengingat pengambilan.',
          ),
          value: _profile.notificationsEnabled,
          onChanged: _profile.setNotifications,
          activeTrackColor: BagiPorsiColors.green,
        ),
      ),
    );
  }

  void _help() {
    showFeatureSheet(
      context,
      title: 'Pusat bantuan',
      icon: Icons.help_outline_rounded,
      message: 'Kenali cara menemukan dan mengambil porsi baik.',
      content: const Column(
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Bagaimana cara mengambil makanan?',
              style: TextStyle(fontSize: 14),
            ),
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Pilih makanan, buka detailnya, lalu hubungi toko lewat Chat untuk memastikan stok, alamat, dan waktu pengambilan.',
                  style: TextStyle(height: 1.5, color: BagiPorsiColors.muted),
                ),
              ),
            ],
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Apakah semua makanan gratis?',
              style: TextStyle(fontSize: 14),
            ),
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Ada pilihan gratis dan pilihan dengan harga hemat. Harga setiap porsi tertera pada kartu makanan.',
                  style: TextStyle(height: 1.5, color: BagiPorsiColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPoints() => showFeatureSheet(
    context,
    title: 'Poin kamu',
    icon: Icons.stars_rounded,
    message: '0 poin terkumpul. Belum ada aktivitas poin untuk ditampilkan.',
  );

  void _showHistory() => openClaims(context, history: true);

  void _showImpact() => showFeatureSheet(
    context,
    title: 'Dampak baikmu',
    icon: Icons.eco_outlined,
    message: 'Setiap porsi berarti. Porsi pertamamu akan menjadi awal dampak baik di sini.',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ImpactStat(
                value: '0',
                label: 'Porsi diselamatkan',
                icon: Icons.restaurant_rounded,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: _ImpactStat(
                value: 'Rp0',
                label: 'Total penghematan',
                icon: Icons.savings_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 76,
          child: CarouselView(
            itemExtent: 230,
            shrinkExtent: 190,
            backgroundColor: BagiPorsiColors.mint,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'SDG 2 · Zero Hunger: kurangi makanan layak konsumsi yang terbuang.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'Ambil tepat waktu sesuai jadwal yang disepakati dengan toko.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _profile,
    builder: (context, child) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [BagiPorsiColors.mint, BagiPorsiColors.canvas],
                      stops: [0, .45],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      _identityCard(),
                      const SizedBox(height: 16),
                      _shortcutPair(
                        _ProfileShortcut(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'Dampak baikmu',
                          subtitle: '0 porsi diselamatkan',
                          featured: true,
                          onTap: _showImpact,
                        ),
                        _ProfileShortcut(
                          icon: Icons.add_location_alt_outlined,
                          title: 'Lokasi pengambilan',
                          subtitle:
                              _profile.location ?? 'Atur lokasi terdekatmu',
                          onTap: _editLocation,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _shortcutPair(
                        _ProfileShortcut(
                          icon: Icons.favorite_rounded,
                          title: 'Restoran favorit',
                          subtitle: '${_profile.favorites.length} tersimpan',
                          compact: true,
                          onTap: _showFavorites,
                        ),
                        _ProfileShortcut(
                          icon: Icons.receipt_long_outlined,
                          title: 'Riwayat pengambilan',
                          subtitle: 'Lihat aktivitasmu',
                          compact: true,
                          onTap: _showHistory,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _groupTitle('Lebih banyak kebaikan'),
                      _menu('Poin kamu', detail: '0 poin', onTap: _showPoints),
                      _menu(
                        'Dampak baikmu',
                        detail: '0 porsi',
                        onTap: _showImpact,
                      ),
                      _groupTitle('Umum'),
                      _menu('Restoran favorit', onTap: _showFavorites),
                      _menu('Riwayat pengambilan', onTap: _showHistory),
                      _menu(
                        'Lokasi tersimpan',
                        subtitle: _profile.location,
                        onTap: _editLocation,
                      ),
                      _menu(
                        'Notifikasi',
                        detail: _profile.notificationsEnabled
                            ? 'Aktif'
                            : 'Nonaktif',
                        onTap: _notificationSettings,
                      ),
                      _groupTitle('Bantuan'),
                      _menu('Pusat bantuan', onTap: _help),
                      _menu(
                        'Tentang BagiPorsi',
                        onTap: () => showFeatureSheet(
                          context,
                          title: 'Porsi baik untuk semua',
                          icon: Icons.volunteer_activism_outlined,
                          message: 'BagiPorsi mempertemukan makanan yang masih tersedia dengan orang yang membutuhkannya. Temukan porsi gratis atau harga hemat, lalu koordinasikan pengambilan dengan toko.',
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'BagiPorsi · Setiap porsi berarti',
                          style: TextStyle(
                            fontSize: 11,
                            color: BagiPorsiColors.muted,
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
    ),
  );

  Widget _identityCard() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: BagiPorsiColors.green,
              child: Text(
                _profile.name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _profile.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BagiPorsiColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Edit profil',
              child: TextButton(
                onPressed: _editName,
                style: TextButton.styleFrom(
                  backgroundColor: BagiPorsiColors.mint,
                  foregroundColor: BagiPorsiColors.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Profil', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _identityBadge(
                Icons.eco_outlined,
                'Setiap porsi berarti',
                _showImpact,
              ),
              const SizedBox(width: 8),
              _identityBadge(
                Icons.stars_rounded,
                '0 poin terkumpul',
                _showPoints,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _identityBadge(IconData icon, String label, VoidCallback onTap) =>
      Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: BagiPorsiColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: BagiPorsiColors.green),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: BagiPorsiColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _shortcutPair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (constraints.maxWidth / scale < 250) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 12), second],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        ),
      );
    },
  );

  Widget _groupTitle(String label) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: BagiPorsiColors.ink,
      ),
    ),
  );

  Widget _menu(
    String title, {
    String? subtitle,
    String? detail,
    required VoidCallback onTap,
  }) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 12,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: BagiPorsiColors.ink),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: BagiPorsiColors.muted,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (detail != null) ...[
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: BagiPorsiColors.muted,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              size: 19,
              color: BagiPorsiColors.muted,
            ),
          ],
        ),
        onTap: onTap,
      ),
      const Divider(height: 1, color: BagiPorsiColors.border),
    ],
  );
}

class _ProfileShortcut extends StatelessWidget {
  const _ProfileShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.featured = false,
    this.compact = false,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool featured, compact;

  @override
  Widget build(BuildContext context) {
    final foreground = featured ? Colors.white : BagiPorsiColors.ink;
    return Material(
      color: featured ? BagiPorsiColors.green : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: featured || compact
              ? Colors.transparent
              : BagiPorsiColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            if (featured)
              Positioned(
                top: -58,
                right: -20,
                child: Container(
                  width: 190,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0x22D2EF94),
                    borderRadius: BorderRadius.all(Radius.elliptical(100, 60)),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(compact ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact) ...[
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: featured
                          ? BagiPorsiColors.lime
                          : BagiPorsiColors.mint,
                      child: Icon(icon, size: 21, color: BagiPorsiColors.green),
                    ),
                    const SizedBox(height: 22),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: compact ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                      ),
                      if (compact) ...[
                        const SizedBox(width: 6),
                        Icon(icon, size: 22, color: BagiPorsiColors.green),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      height: 1.4,
                      color: featured
                          ? const Color(0xFFD2EAE2)
                          : BagiPorsiColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value, label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BagiPorsiColors.green, size: 24),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: BagiPorsiColors.ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            height: 1.5,
            color: BagiPorsiColors.muted,
          ),
        ),
      ],
    ),
  );
}
