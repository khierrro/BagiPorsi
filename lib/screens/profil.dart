import 'package:flutter/material.dart';

import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';
import '../widgets/home_quick_actions.dart';

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

  Future<void> _editName() async {
    final name = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => _EditNameSheet(name: _profile.name),
    );
    if (name != null) _profile.updateName(name);
  }

  void _showFavorites() {
    showFeatureSheet(
      context,
      title: 'Restoran favorit',
      icon: Icons.favorite_border_rounded,
      message: _profile.favorites.isEmpty
          ? 'Belum ada restoran favorit. Ketuk ikon hati pada kartu makanan di Peta untuk menyimpannya.'
          : 'Tempat pilihanmu untuk menemukan porsi baik berikutnya.',
      content: ListenableBuilder(
        listenable: _profile,
        builder: (context, child) => Column(
          children: [
            for (final food in foodCatalog.where(
              (food) => _profile.isFavorite(food.merchantName),
            ))
              ListTile(
                contentPadding: EdgeInsets.zero,
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
                  onPressed: () => _profile.toggleFavorite(food.merchantName),
                  icon: const Icon(
                    Icons.favorite,
                    color: BagiPorsiColors.green,
                  ),
                ),
                onTap: () => openFoodDetails(context, food),
              ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _profile,
    builder: (context, child) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profil',
            onPressed: _editName,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: BagiPorsiColors.mint,
                  child: Text(
                    _profile.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: BagiPorsiColors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo,',
                        style: TextStyle(
                          fontSize: 12,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Setiap porsi berarti.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: BagiPorsiColors.border),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            leading: const Icon(
              Icons.stars_rounded,
              color: BagiPorsiColors.green,
              size: 30,
            ),
            title: const Text(
              'Poin kamu',
              style: TextStyle(fontSize: 13, color: BagiPorsiColors.muted),
            ),
            subtitle: const Text(
              '0 poin',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: BagiPorsiColors.green,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: BagiPorsiColors.muted,
            ),
            onTap: () => showFeatureSheet(
              context,
              title: 'Poin kamu',
              icon: Icons.stars_rounded,
              message: '0 poin terkumpul. Belum ada aktivitas poin untuk ditampilkan.',
            ),
          ),
          const Divider(height: 1, color: BagiPorsiColors.border),
          _groupTitle('Dampak baikmu'),
          const Text(
            'Langkah kecilmu, berarti untuk bumi.',
            style: TextStyle(fontSize: 12, color: BagiPorsiColors.muted),
          ),
          const SizedBox(height: 20),
          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ImpactStat(
                    value: '0',
                    label: 'Porsi diselamatkan',
                    icon: Icons.restaurant_rounded,
                  ),
                ),
                VerticalDivider(
                  width: 32,
                  thickness: 1,
                  color: BagiPorsiColors.border,
                ),
                Expanded(
                  child: _ImpactStat(
                    value: 'Rp0',
                    label: 'Total penghematan',
                    icon: Icons.savings_outlined,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: BagiPorsiColors.border),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: BagiPorsiColors.green,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mulai langkah baikmu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Porsi pertamamu akan menjadi awal dampak baik di sini.',
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
          const Divider(height: 1, color: BagiPorsiColors.border),
          _groupTitle('Aktivitas'),
          _menuGroup([
            _menu(
              Icons.receipt_long_outlined,
              'Riwayat pengambilan',
              subtitle: 'Lihat perjalanan porsi baikmu',
              onTap: () => showFeatureSheet(
                context,
                title: 'Riwayat pengambilan',
                icon: Icons.receipt_long_outlined,
                message: 'Belum ada pengambilan. Jelajahi Beranda atau Peta untuk menemukan makanan pilihanmu.',
              ),
            ),
            _menu(
              Icons.favorite_border_rounded,
              'Restoran favorit',
              subtitle: '${_profile.favorites.length} restoran tersimpan',
              onTap: _showFavorites,
            ),
          ]),
          _groupTitle('Preferensi'),
          _menuGroup([
            _menu(
              Icons.location_on_outlined,
              'Lokasi tersimpan',
              subtitle: _profile.location ?? 'Atur area pengambilanmu',
              onTap: () => chooseUserLocation(context, _profile),
            ),
            _menu(
              Icons.notifications_none_rounded,
              'Notifikasi',
              subtitle: _profile.notificationsEnabled
                  ? 'Pengingat diaktifkan'
                  : 'Pengingat dinonaktifkan',
              onTap: _notificationSettings,
            ),
          ]),
          _groupTitle('Bantuan'),
          _menuGroup([
            _menu(Icons.help_outline_rounded, 'Pusat bantuan', onTap: _help),
            _menu(
              Icons.volunteer_activism_outlined,
              'Tentang BagiPorsi',
              onTap: () => showFeatureSheet(
                context,
                title: 'Porsi baik untuk semua',
                icon: Icons.volunteer_activism_outlined,
                message: 'BagiPorsi mempertemukan makanan yang masih tersedia dengan orang yang membutuhkannya. Temukan porsi gratis atau harga hemat, lalu koordinasikan pengambilan dengan toko.',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'BagiPorsi · Setiap porsi berarti',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: BagiPorsiColors.muted),
          ),
        ],
      ),
    ),
  );

  Widget _groupTitle(String label) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: BagiPorsiColors.ink,
      ),
    ),
  );

  Widget _menuGroup(List<Widget> children) => Column(
    children: [
      for (final child in children) ...[
        child,
        const Divider(height: 1, color: BagiPorsiColors.border),
      ],
    ],
  );

  Widget _menu(
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
    leading: Icon(icon, size: 23, color: BagiPorsiColors.green),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: BagiPorsiColors.ink,
      ),
    ),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: BagiPorsiColors.muted),
          ),
    trailing: const Icon(
      Icons.chevron_right,
      size: 19,
      color: BagiPorsiColors.muted,
    ),
    onTap: onTap,
  );
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

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.name});
  final String name;
  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final _controller = TextEditingController(text: widget.name);
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit profil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BagiPorsiColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nama yang tampil di profilmu.',
              style: TextStyle(color: BagiPorsiColors.muted),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              maxLength: 50,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama tidak boleh kosong.'
                  : null,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(context, _controller.text.trim());
                }
              },
              child: const Text('Simpan perubahan'),
            ),
          ],
        ),
      ),
    ),
  );
}
