import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/claim_store.dart';
import '../data/food_catalog.dart';
import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/feature_widgets.dart';
import 'lokasi.dart';

class CheckoutMakanan extends StatefulWidget {
  const CheckoutMakanan({
    super.key,
    required this.food,
    required this.quantity,
    required this.claims,
    required this.profile,
  });

  final FoodListing food;
  final int quantity;
  final ClaimStore claims;
  final UserProfileStore profile;

  @override
  State<CheckoutMakanan> createState() => _CheckoutMakananState();
}

class _CheckoutMakananState extends State<CheckoutMakanan> {
  bool _submitting = false;

  SavedLocation? get _location {
    for (final place in widget.profile.savedLocations) {
      if (place.id == widget.profile.activeLocationId) return place;
    }
    return null;
  }

  String get _total {
    if (widget.food.isFree) return 'Gratis';
    final price = int.tryParse(
      widget.food.discountPrice.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    return price == null
        ? widget.food.discountPrice
        : rupiah(price * widget.quantity);
  }

  Future<void> _chooseLocation() async {
    await Navigator.of(context).push<SavedLocation>(
      MaterialPageRoute(
        builder: (_) =>
            LokasiPage(profile: widget.profile, selectionMode: true),
      ),
    );
  }

  Future<void> _confirm() async {
    final location = _location;
    if (_submitting || widget.claims.busy || location == null) return;
    setState(() => _submitting = true);
    try {
      final claim = await widget.claims.create(
        widget.food,
        widget.quantity,
        userLocation: ClaimLocation(
          label: location.label,
          address: location.address,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, claim);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message.toString()
                : 'Klaim belum tersimpan. Coba lagi.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.claims, widget.profile]),
    builder: (context, _) {
      final location = _location;
      final inStock =
          widget.quantity > 0 &&
          widget.quantity <= widget.claims.available(widget.food);
      final busy = _submitting || widget.claims.busy;
      final canConfirm =
          widget.claims.loaded && !busy && inStock && location != null;
      return PopScope(
        canPop: !_submitting,
        child: Scaffold(
          backgroundColor: BagiPorsiColors.canvas,
          appBar: AppBar(
            title: const Text(
              'Checkout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            backgroundColor: Colors.white,
            foregroundColor: BagiPorsiColors.ink,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card.outlined(
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: BagiPorsiColors.border,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    const Text(
                                      'Lokasi pengguna',
                                      style: _heading,
                                    ),
                                    TextButton.icon(
                                      onPressed: busy ? null : _chooseLocation,
                                      icon: Icon(
                                        location == null
                                            ? Icons.add_location_alt_outlined
                                            : Icons.edit_location_alt_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        location == null
                                            ? 'Pilih lokasi'
                                            : 'Ubah lokasi',
                                      ),
                                    ),
                                  ],
                                ),
                                if (location == null)
                                  const Text(
                                    'Pilih alamat dari tempat tersimpan atau tambahkan alamat baru.',
                                    style: _muted,
                                  )
                                else ...[
                                  Text(
                                    location.label,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: BagiPorsiColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    location.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: BagiPorsiColors.ink,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                const Text(
                                  'Alamat ini menjadi acuan lokasi pengguna. Makanan tetap diambil langsung di toko.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: BagiPorsiColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Ringkasan pengambilan', style: _heading),
                        const SizedBox(height: 12),
                        Card.outlined(
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(
                              color: BagiPorsiColors.border,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FoodPhoto(
                                      food: widget.food,
                                      size: 56,
                                      radius: 12,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.food.foodName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: BagiPorsiColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            widget.food.merchantName,
                                            style: _muted,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _CheckoutLine(
                                  'Jumlah porsi',
                                  '${widget.quantity} porsi',
                                ),
                                const SizedBox(height: 12),
                                _CheckoutLine(
                                  'Harga per porsi',
                                  widget.food.discountPrice,
                                ),
                                const Divider(
                                  height: 28,
                                  color: BagiPorsiColors.border,
                                ),
                                _CheckoutLine(
                                  'Pembayaran',
                                  widget.food.isFree
                                      ? 'Tanpa pembayaran'
                                      : 'Tunai saat ambil',
                                ),
                                const SizedBox(height: 12),
                                _CheckoutLine('Total', _total, emphasis: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: BagiPorsiColors.mint,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: BagiPorsiColors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ambil langsung di ${widget.food.merchantName}. Pastikan alamat dan waktu pengambilan dengan toko sebelum berangkat.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: BagiPorsiColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Klaim demo disimpan di perangkat ini, belum dikirim ke penjual. Kode berlaku 2 jam untuk simulasi.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                        if (!inStock) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Stok berubah. Kembali ke detail untuk menyesuaikan jumlah porsi.',
                            style: TextStyle(color: Color(0xFFBB5547)),
                          ),
                        ],
                        if (widget.claims.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.claims.error!,
                            style: const TextStyle(color: Color(0xFFBB5547)),
                          ),
                          TextButton(
                            onPressed: busy ? null : widget.claims.load,
                            child: const Text('Coba muat ulang'),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: busy ? null : () => Navigator.pop(context),
                          child: const Text('Kembali ke detail'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: BagiPorsiColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CheckoutLine(
                          'Total · ${widget.quantity} porsi',
                          _total,
                          emphasis: true,
                        ),
                        if (location == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Pilih lokasi pengguna untuk melanjutkan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: BagiPorsiColors.muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: canConfirm ? _confirm : null,
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(
                            busy ? 'Menyimpan klaim…' : 'Konfirmasi klaim',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  static const _heading = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: BagiPorsiColors.ink,
  );
  static const _muted = TextStyle(
    fontSize: 13,
    height: 1.5,
    color: BagiPorsiColors.muted,
  );
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine(this.label, this.value, {this.emphasis = false});
  final String label, value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: BagiPorsiColors.muted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: emphasis ? 20 : 13,
            fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
            color: BagiPorsiColors.green,
          ),
        ),
      ),
    ],
  );
}
