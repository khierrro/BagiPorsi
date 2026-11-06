import 'package:flutter/material.dart';

import '../design/bagi_porsi_theme.dart';
import '../data/user_profile_store.dart';
import 'claim_scope.dart';

Future<void> chooseUserLocation(
  BuildContext context,
  UserProfileStore profile,
) async {
  final location = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => _LocationForm(initialLocation: profile.location),
  );
  if (location != null) profile.updateLocation(location);
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
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.stars_rounded,
                color: BagiPorsiColors.green,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                '0 poin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Belum ada poin terkumpul',
                textAlign: TextAlign.center,
                style: TextStyle(color: BagiPorsiColors.muted),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Jelajahi makanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = ClaimScope.maybeOf(context)?.store.latest;
    final extraHeight =
        (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0.0, 28.0) * 3;
    return ListenableBuilder(
      listenable: _profile,
      builder: (context, child) {
        final actions = [
          _QuickAction(
            title: 'Poin kamu',
            value: '0 poin',
            detail: 'Lihat poin terkumpul',
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
            detail: _profile.location == null
                ? 'Pilih area di sekitarmu'
                : 'Ubah lokasi',
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

class _LocationForm extends StatefulWidget {
  const _LocationForm({this.initialLocation});

  final String? initialLocation;

  @override
  State<_LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<_LocationForm> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialLocation);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Lokasi kamu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan nama area atau alamat pengambilanmu.',
                style: TextStyle(color: BagiPorsiColors.muted),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Area atau alamat',
                  hintText: 'Contoh: Kecamatan Coblong, Bandung',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Isi area atau alamat terlebih dahulu.'
                    : null,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, _controller.text.trim());
                  }
                },
                child: const Text('Simpan lokasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
