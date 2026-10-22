import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/bagi_porsi_theme.dart';

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
  });

  final String merchantName, foodName, distance;
  final String originalPrice, discountPrice, imageUrl;
  final int portionsLeft;
  final bool isFree;

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.portionsLeft > 0 ? 1 : 0;
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
          child: Column(
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
              const SizedBox(height: 20),
              const _PickupNote(),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke detail'),
              ),
            ],
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail makanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
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
                  _buildPhoto(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.foodName,
                          style: const TextStyle(
                            fontSize: 28,
                            height: 1.2,
                            letterSpacing: -0.6,
                            fontWeight: FontWeight.w800,
                            color: BagiPorsiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              widget.discountPrice,
                              style: const TextStyle(
                                color: BagiPorsiColors.green,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.originalPrice,
                              style: const TextStyle(
                                color: BagiPorsiColors.muted,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const Text('/ porsi', style: _bodyStyle),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildMerchant(),
                        const SizedBox(height: 28),
                        const Text('Porsi baik untukmu', style: _sectionTitle),
                        const SizedBox(height: 8),
                        const Text(
                          'Selamatkan makanan dengan memilih porsi sesuai '
                          'kebutuhanmu. Satu porsi kecil, satu langkah baik '
                          'untuk mengurangi makanan terbuang.',
                          style: _bodyStyle,
                        ),
                        const SizedBox(height: 24),
                        _buildQuantity(),
                        const SizedBox(height: 24),
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
                      onPressed: _quantity > 0 ? _showSummary : null,
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
    );
  }

  Widget _buildPhoto() => Stack(
    children: [
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          semanticLabel: widget.foodName,
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: BagiPorsiColors.mint,
            child: Center(
              child: Icon(
                Icons.restaurant_rounded,
                color: BagiPorsiColors.green,
                size: 64,
                semanticLabel: 'Gambar makanan tidak tersedia',
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 20,
        bottom: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.isFree
                ? BagiPorsiColors.green
                : const Color(0xFFFFE3BA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              widget.isFree ? 'Porsi gratis' : 'Harga hemat',
              style: TextStyle(
                color: widget.isFree ? Colors.white : const Color(0xFF7C4600),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildMerchant() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: BagiPorsiColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: BagiPorsiColors.mint,
          child: Icon(Icons.storefront_outlined, color: BagiPorsiColors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.merchantName,
                style: const TextStyle(
                  color: BagiPorsiColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('${widget.distance} dari lokasimu', style: _bodyStyle),
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
        Text('${widget.portionsLeft} porsi tersedia', style: _bodyStyle),
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
              onPressed: _quantity < widget.portionsLeft
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: BagiPorsiColors.muted, height: 1.4),
        ),
      ),
      const SizedBox(width: 16),
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
