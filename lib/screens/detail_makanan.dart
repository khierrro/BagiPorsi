import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/bagi_porsi_theme.dart';
import '../data/claim_store.dart';
import '../data/food_catalog.dart';
import '../widgets/claim_scope.dart';
import 'klaim_saya.dart';

class DetailMakanan extends StatefulWidget {
  const DetailMakanan({
    super.key,
    required this.merchantName,
    required this.foodName,
    required this.distance,
    required this.portionsLeft,
    required this.originalPrice,
    required this.discountPrice,
    required this.imageUrl,
    required this.isFree,
    this.initialIsFavorite = false,
    this.onToggleFavorite,
  });

  final String merchantName, foodName, distance;
  final String originalPrice, discountPrice, imageUrl;
  final int portionsLeft;
  final bool isFree;
  final bool initialIsFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  late int _quantity;
  late bool _isFavorite;
  ClaimStore? _claims;
  bool _ownsClaims = false;
  FoodListing get _food => FoodListing(
    widget.merchantName,
    widget.foodName,
    widget.distance,
    widget.portionsLeft,
    widget.originalPrice,
    widget.discountPrice,
    widget.imageUrl,
    widget.isFree,
    const [],
  );
  int get _available => _claims?.available(_food) ?? widget.portionsLeft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_claims == null) {
      _claims = ClaimScope.maybeOf(context)?.store;
      _ownsClaims = _claims == null;
      _claims ??= ClaimStore();
      _claims!.addListener(_claimsChanged);
    }
    if (_quantity > _available) _quantity = _available;
  }

  void _claimsChanged() {
    if (!mounted) return;
    setState(() {
      if (_quantity > _available) _quantity = _available;
      if (_quantity == 0 && _available > 0) _quantity = 1;
    });
  }

  @override
  void dispose() {
    _claims?.removeListener(_claimsChanged);
    if (_ownsClaims) _claims?.dispose();
    super.dispose();
  }

  Future<void> _confirmClaim(BuildContext sheetContext) async {
    try {
      await _claims!.create(_food, _quantity);
      if (!mounted || !sheetContext.mounted) return;
      Navigator.pop(sheetContext);
      final openTab = ClaimScope.maybeOf(context)?.onOpenClaims;
      if (openTab != null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        openTab();
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => KlaimSaya(store: _claims)),
      );
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
    }
  }

  @override
  void initState() {
    super.initState();
    _quantity = widget.portionsLeft > 0 ? 1 : 0;
    _isFavorite = widget.initialIsFavorite;
  }

  String get _total {
    if (widget.isFree) return 'Gratis';
    final unitPrice = int.tryParse(
      widget.discountPrice.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (unitPrice == null) return widget.discountPrice;
    final amount = (unitPrice * _quantity).toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $amount';
  }

  void _showSummary() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: ListenableBuilder(
            listenable: _claims!,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Ringkasan pengambilan', style: _sectionTitle),
                const SizedBox(height: 20),
                Text(widget.foodName, style: _sectionTitle),
                const SizedBox(height: 6),
                Text(widget.merchantName, style: _bodyStyle),
                const SizedBox(height: 20),
                _SummaryRow(label: 'Jumlah porsi', value: '$_quantity porsi'),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Harga per porsi',
                  value: widget.discountPrice,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: BagiPorsiColors.border),
                ),
                _SummaryRow(label: 'Total', value: _total, emphasis: true),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Pembayaran',
                  value: widget.isFree
                      ? 'Tanpa pembayaran'
                      : 'Tunai saat ambil',
                ),
                const SizedBox(height: 20),
                const _PickupNote(),
                const SizedBox(height: 16),
                const Text(
                  'Klaim demo disimpan di perangkat ini, belum dikirim ke penjual. Kode berlaku 2 jam untuk simulasi.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: BagiPorsiColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                if (_claims!.error != null) ...[
                  Text(
                    _claims!.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: _claims!.busy ? null : _claims!.load,
                    child: const Text('Coba muat ulang'),
                  ),
                ],
                FilledButton(
                  onPressed: _claims!.busy || !_claims!.loaded || _quantity <= 0
                      ? null
                      : () => _confirmClaim(context),
                  child: Text(
                    _claims!.busy ? 'Menyimpan klaim…' : 'Konfirmasi klaim',
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali ke detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _sectionTitle = TextStyle(
    fontSize: 19,
    height: 1.3,
    color: BagiPorsiColors.ink,
    fontWeight: FontWeight.w800,
  );
  static const _bodyStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: BagiPorsiColors.muted,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroWithFloatingMerchantCard(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Menu tersedia', style: _sectionTitle),
                          const SizedBox(height: 12),
                          _buildFeaturedMenuCard(),
                          const SizedBox(height: 22),
                          const Text('Atur jumlah porsi', style: _sectionTitle),
                          const SizedBox(height: 10),
                          _buildQuantity(),
                          const SizedBox(height: 20),
                          const _PickupNote(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
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
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SummaryRow(
                        label: 'Total · $_quantity porsi',
                        value: _total,
                        emphasis: true,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _quantity > 0 && !(_claims?.busy ?? false)
                            ? _showSummary
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: BagiPorsiColors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _quantity > 0 ? 'Lanjut ambil' : 'Porsi habis',
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
  }

  Widget _buildHeroWithFloatingMerchantCard(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        SizedBox(
          height: 196 + topInset,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                semanticLabel: widget.foodName,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: BagiPorsiColors.deepGreen,
                  child: Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white54,
                      size: 56,
                      semanticLabel: 'Gambar makanan tidak tersedia',
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x88000000), Color(0x55000000)],
                  ),
                ),
              ),
              Positioned(
                top: topInset + 12,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    const Material(
                      color: Color(0x78000000),
                      shape: CircleBorder(),
                      child: BackButton(color: Colors.white),
                    ),
                    const Spacer(),
                    Material(
                      color: const Color(0x78000000),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: _isFavorite
                            ? 'Hapus favorit'
                            : 'Simpan favorit',
                        onPressed: () {
                          setState(() => _isFavorite = !_isFavorite);
                          widget.onToggleFavorite?.call();
                        },
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isFavorite
                              ? const Color(0xFFFF5252)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 118 + topInset, 16, 0),
          child: _buildFloatingMerchantCard(),
        ),
      ],
    );
  }

  Widget _buildFloatingMerchantCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: BagiPorsiColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18183C32),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 82,
            height: 82,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: BagiPorsiColors.mint,
                child: Icon(
                  Icons.storefront_rounded,
                  color: BagiPorsiColors.green,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF3FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: Color(0xFF0277BD),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Pelayanan Bagus',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF01579B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.merchantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BagiPorsiColors.ink,
                  fontSize: 18,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '- Sekitar ${widget.distance}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BagiPorsiColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFFFB300),
                  ),
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                  const Text(
                    '(100+)',
                    style: TextStyle(
                      fontSize: 12,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                  const Text(
                    '·',
                    style: TextStyle(color: BagiPorsiColors.muted),
                  ),
                  Text(
                    widget.isFree ? 'Bebas biaya' : 'Porsi hemat',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD86B1F),
                    ),
                  ),
                  const Text(
                    '· Siap 15 menit',
                    style: TextStyle(fontSize: 12, color: BagiPorsiColors.ink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildFeaturedMenuCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: BagiPorsiColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D183C32),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: BagiPorsiColors.mint,
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: BagiPorsiColors.green,
                          size: 32,
                        ),
                      ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    color: widget.isFree
                        ? BagiPorsiColors.green
                        : const Color(0xFFEF6C00),
                    child: Text(
                      widget.isFree ? 'Porsi gratis' : 'Harga hemat',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.foodName,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.discountPrice,
                    style: const TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.originalPrice,
                    style: const TextStyle(
                      color: BagiPorsiColors.muted,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sisa $_available porsi · Siap diambil',
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
  );

  Widget _buildQuantity() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BagiPorsiColors.lime,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mau ambil berapa porsi?', style: _sectionTitle),
        const SizedBox(height: 4),
        Text('$_available porsi tersedia', style: _bodyStyle),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: 'Kurangi porsi',
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$_quantity',
                style: _sectionTitle,
                semanticsLabel: '$_quantity porsi dipilih',
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Tambah porsi',
              onPressed: _quantity < _available
                  ? () => setState(() => _quantity++)
                  : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PickupNote extends StatelessWidget {
  const _PickupNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BagiPorsiColors.canvas,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shopping_bag_outlined, color: BagiPorsiColors.green),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ambil langsung di toko',
                style: TextStyle(
                  color: BagiPorsiColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Pastikan lokasi dan waktu pengambilan dengan toko '
                'sebelum berangkat.',
                style: TextStyle(
                  color: BagiPorsiColors.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label, value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Flexible(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            label,
            style: const TextStyle(color: BagiPorsiColors.muted, height: 1.4),
          ),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: emphasis ? 21 : 14,
            color: BagiPorsiColors.green,
            fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
