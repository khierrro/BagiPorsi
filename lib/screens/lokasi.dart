import 'package:flutter/material.dart';

import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({
    super.key,
    required this.profile,
    this.selectionMode = false,
  });

  final UserProfileStore profile;
  final bool selectionMode;

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  Future<void> _openPlaceSheet({required SavedPlaceKind kind}) async {
    final saved = await showModalBottomSheet<SavedLocation>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) =>
          _SavePlaceSheet(profile: widget.profile, kind: kind),
    );
    if (saved != null && mounted) {
      if (widget.selectionMode) {
        Navigator.pop(context, saved);
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${saved.label} disimpan dan dijadikan lokasi aktif.',
            ),
          ),
        );
    }
  }

  void _selectPlace(SavedLocation place) {
    widget.profile.selectLocation(place.id);
    if (widget.selectionMode) {
      Navigator.pop(context, place);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Lokasi aktif diubah ke ${place.label}.')),
      );
  }

  void _deletePlace(SavedLocation place) {
    widget.profile.removeLocation(place.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${place.label} dihapus dari tempat tersimpan.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.profile,
      builder: (context, _) {
        final home = widget.profile.homeLocation;
        final work = widget.profile.workLocation;
        final custom = widget.profile.customLocations;
        final activeId = widget.profile.activeLocationId;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: BagiPorsiColors.ink,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: widget.selectionMode
                ? const BackButton()
                : IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 26),
                  ),
            title: Text(
              widget.selectionMode ? 'Pilih lokasi' : 'Tempat Tersimpan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: BagiPorsiColors.ink,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: BagiPorsiColors.border),
            ),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    if (home != null)
                      _SavedPlaceTile(
                        icon: Icons.home_rounded,
                        iconFilled: true,
                        title: home.label,
                        subtitle: '${home.distanceLabel}  •  ${home.address}',
                        isActive: activeId == home.id,
                        onTap: () => _selectPlace(home),
                        onDelete: () => _deletePlace(home),
                      )
                    else
                      _ActionPlaceTile(
                        icon: Icons.home_outlined,
                        title: 'Tambahkan rumah',
                        onTap: () => _openPlaceSheet(kind: SavedPlaceKind.home),
                      ),
                    const _PlaceDivider(),
                    if (work != null)
                      _SavedPlaceTile(
                        icon: Icons.work_rounded,
                        iconFilled: true,
                        title: work.label,
                        subtitle: '${work.distanceLabel}  •  ${work.address}',
                        isActive: activeId == work.id,
                        onTap: () => _selectPlace(work),
                        onDelete: () => _deletePlace(work),
                      )
                    else
                      _ActionPlaceTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Tambahkan tempat kerja',
                        onTap: () => _openPlaceSheet(kind: SavedPlaceKind.work),
                      ),
                    const _PlaceDivider(),
                    for (final place in custom) ...[
                      _SavedPlaceTile(
                        icon: Icons.location_on_rounded,
                        iconFilled: true,
                        title: place.label,
                        subtitle: '${place.distanceLabel}  •  ${place.address}',
                        isActive: activeId == place.id,
                        onTap: () => _selectPlace(place),
                        onDelete: () => _deletePlace(place),
                      ),
                      const _PlaceDivider(),
                    ],
                    _ActionPlaceTile(
                      icon: Icons.add_rounded,
                      title: 'Tambah baru',
                      subtitle: 'Simpan tempat favoritmu',
                      onTap: () => _openPlaceSheet(kind: SavedPlaceKind.custom),
                    ),
                    const _PlaceDivider(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceDivider extends StatelessWidget {
  const _PlaceDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF0F2F3),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  const _SavedPlaceTile({
    required this.icon,
    required this.iconFilled,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final IconData icon;
  final bool iconFilled;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconFilled
                    ? BagiPorsiColors.mint
                    : const Color(0xFFF2F4F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconFilled
                    ? BagiPorsiColors.green
                    : BagiPorsiColors.muted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BagiPorsiColors.mint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: BagiPorsiColors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus $title',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: BagiPorsiColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPlaceTile extends StatelessWidget {
  const _ActionPlaceTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: BagiPorsiColors.muted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: BagiPorsiColors.green,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: BagiPorsiColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavePlaceSheet extends StatefulWidget {
  const _SavePlaceSheet({required this.profile, required this.kind});

  final UserProfileStore profile;
  final SavedPlaceKind kind;

  @override
  State<_SavePlaceSheet> createState() => _SavePlaceSheetState();
}

class _SavePlaceSheetState extends State<_SavePlaceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _labelController = TextEditingController(
    text: switch (widget.kind) {
      SavedPlaceKind.home => 'Rumah',
      SavedPlaceKind.work => 'Tempat Kerja',
      SavedPlaceKind.custom => '',
    },
  );
  final _addressController = TextEditingController();

  static const _quickLabels = ['Kampus', 'Kos', 'Orang Tua', 'Gym'];

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final saved = widget.profile.savePlace(
      label: _labelController.text.trim(),
      address: _addressController.text.trim(),
      kind: widget.kind,
    );
    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = widget.kind == SavedPlaceKind.custom;
    final sheetTitle = switch (widget.kind) {
      SavedPlaceKind.home => 'Simpan alamat Rumah',
      SavedPlaceKind.work => 'Simpan Tempat Kerja',
      SavedPlaceKind.custom => 'Tambah tempat baru',
    };

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          4,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                sheetTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masukkan detail lokasi untuk mempermudah pengambilan makananmu.',
                style: TextStyle(color: BagiPorsiColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              if (isCustom) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in _quickLabels)
                      ActionChip(
                        label: Text(preset),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: BagiPorsiColors.border),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BagiPorsiColors.ink,
                        ),
                        onPressed: () {
                          _labelController.text = preset;
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('place-label-field'),
                  controller: _labelController,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama tempat',
                    hintText: 'Contoh: Kampus, Kos, Rumah Nenek',
                    prefixIcon: Icon(Icons.bookmark_border_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Isi nama tempat terlebih dahulu.'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const ValueKey('place-address-field'),
                controller: _addressController,
                autofocus: !isCustom,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Area atau alamat',
                  hintText: 'Contoh: Perumahan Sentosa Park, Abadi Cluster',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Isi area atau alamat terlebih dahulu.'
                    : null,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                child: const Text('Simpan lokasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
