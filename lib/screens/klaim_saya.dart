import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/chat_store.dart';
import '../data/claim_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/claim_scope.dart';
import '../widgets/feature_widgets.dart';
import 'chat_penjual.dart';

void openClaims(BuildContext context, {bool history = false}) {
  final openTab = ClaimScope.maybeOf(context)?.onOpenClaims;
  if (!history && openTab != null) {
    openTab();
    return;
  }
  Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => KlaimSaya(initialHistory: history)),
  );
}

class KlaimSaya extends StatefulWidget {
  const KlaimSaya({
    super.key,
    this.store,
    this.initialHistory = false,
    this.embedded = false,
  });
  final ClaimStore? store;
  final bool initialHistory, embedded;
  @override
  State<KlaimSaya> createState() => _KlaimSayaState();
}

class _KlaimSayaState extends State<KlaimSaya> with WidgetsBindingObserver {
  ClaimStore? _store;
  bool _ownsStore = false;
  late bool _history = widget.initialHistory;
  final _fallbackChat = ChatStore();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _store?.refreshExpiry(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_store == null) {
      _store = widget.store ?? ClaimScope.maybeOf(context)?.store;
      _ownsStore = _store == null;
      _store ??= ClaimStore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _store?.refreshExpiry();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsStore) _store?.dispose();
    _fallbackChat.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message.toString()
                : 'Perubahan belum tersimpan. Coba lagi.',
          ),
        ),
      );
    }
  }

  void _contact(FoodClaim claim) {
    final chat = ClaimScope.maybeOf(context)?.chatStore ?? _fallbackChat;
    if (chat.draftFor(claim.food.merchantName).isEmpty) {
      chat.saveDraft(
        claim.food.merchantName,
        'Halo, saya ingin memastikan stok dan waktu pengambilan ${claim.quantity} porsi ${claim.food.foodName}. Kode simulasi saya ${claim.code}.',
      );
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChatPenjual(restaurant: claim.food, store: chat),
      ),
    );
  }

  void _directions(FoodClaim claim) => showFeatureSheet(
    context,
    title: 'Petunjuk pengambilan',
    icon: Icons.directions_walk_rounded,
    message:
        'Ambil langsung di ${claim.food.merchantName}. Alamat toko belum tersedia di katalog contoh. Pastikan alamat, stok, dan jam pengambilan melalui Chat sebelum berangkat.',
    content: FilledButton.icon(
      onPressed: () {
        Navigator.pop(context);
        _contact(claim);
      },
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('Tanyakan alamat ke penjual'),
    ),
  );

  Future<void> _cancel(FoodClaim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan klaim?'),
        content: Text(
          '${claim.quantity} porsi ${claim.food.foodName} akan dilepas kembali ke stok demo. Klaim tetap tersimpan di Riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tetap simpan'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() => _store!.cancel(claim.code));
    }
  }

  Future<void> _collect(FoodClaim claim, {BuildContext? sheetContext}) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan pengambilan?'),
        content: Text(
          'Konfirmasi bahwa ${claim.quantity} porsi ${claim.food.foodName} sudah kamu ambil di ${claim.food.merchantName}. Kamu akan mendapatkan +${claim.pointsEarned} poin kebaikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, sudah diambil'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      await _run(() => _store!.collect(claim.code));
      if (!mounted) return;
      final collected = _store!.history.any(
        (c) => c.code == claim.code && c.status == ClaimStatus.collected,
      );
      if (collected) {
        if (sheetContext != null && sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengambilan selesai! +${claim.pointsEarned} poin kebaikan ditambahkan.',
            ),
          ),
        );
      }
    }
  }

  void _showCode(FoodClaim claim) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ListenableBuilder(
            listenable: _store!,
            builder: (context, _) {
              final active =
                  _store!.statusOf(
                    _store!.claims.firstWhere((c) => c.code == claim.code),
                  ) ==
                  ClaimStatus.active;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Tutup kode',
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const Text(
                    'Kode pengambilan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    claim.food.merchantName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: BagiPorsiColors.muted),
                  ),
                  const SizedBox(height: 18),
                  if (active)
                    Center(
                      child: QrImageView(
                        data: 'BAGIPORSI-DEMO|${claim.code}',
                        size: 200,
                        backgroundColor: Colors.white,
                        semanticsLabel: 'QR simulasi untuk ${claim.code}',
                      ),
                    ),
                  SelectableText(
                    claim.code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: BagiPorsiColors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    active
                        ? 'QR simulasi, belum terhubung ke sistem penjual. Jangan lakukan pembayaran berdasarkan kode demo ini.'
                        : 'Klaim ini sudah tidak aktif.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: claim.code));
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Kode klaim disalin')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Salin kode'),
                  ),
                  if (active)
                    FilledButton(
                      onPressed: _store!.busy
                          ? null
                          : () => _collect(claim, sheetContext: sheetContext),
                      child: const Text('Simulasikan pengambilan'),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _store!,
    builder: (context, _) {
      final claims = _history ? _store!.history : _store!.active;
      return Scaffold(
        backgroundColor: BagiPorsiColors.canvas,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.elliptical(220, 18),
                    bottomRight: Radius.elliptical(220, 18),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          BagiPorsiColors.green,
                          BagiPorsiColors.deepGreen,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(painter: _HeaderStripes()),
                          ),
                        ),
                        Positioned(
                          right: 22,
                          top: 55,
                          child: Transform.rotate(
                            angle: -.13,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0x18FFFFFF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: Color(0xAAFFFFFF),
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!widget.embedded)
                                  BackButton(
                                    onPressed: () => Navigator.pop(context),
                                    color: Colors.white,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 88),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'AMBIL & BAGI KEBAIKAN',
                                        style: TextStyle(
                                          color: Color(0xFFBFE5D5),
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Klaim Saya',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          height: 1.15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _store!.activePortions == 0
                                            ? 'Porsi baik berikutnya menantimu'
                                            : '${_store!.activePortions} porsi menunggu kamu ambil',
                                        style: const TextStyle(
                                          color: Color(0xFFD2EAE2),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _tab(
                                      'Aktif (${_store!.active.length})',
                                      false,
                                    ),
                                    _tab(
                                      'Riwayat (${_store!.history.length})',
                                      true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Text(
                    'Mode demo · Klaim disimpan di perangkat ini dan belum dikirim ke penjual. Batas pengambilan simulasi: 2 jam.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                ),
              ),
              if (!_store!.loaded)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(_store!.error ?? 'Memuat klaim…'),
                        if (!_store!.busy)
                          TextButton(
                            onPressed: _store!.load,
                            child: const Text('Coba muat ulang'),
                          ),
                      ],
                    ),
                  ),
                )
              else if (claims.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: BagiPorsiColors.mint,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 36,
                            color: BagiPorsiColors.green,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _history
                              ? 'Belum ada riwayat klaim'
                              : 'Belum ada klaim aktif',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: BagiPorsiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _history
                              ? 'Klaim yang sudah diambil, dibatalkan, atau kedaluwarsa akan muncul di sini.'
                              : 'Pilih makanan di Beranda atau Peta, lalu konfirmasi klaim untuk mendapatkan kode pengambilan.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: claims.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: _card(claims[index]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );

  Widget _tab(String label, bool history) => ChoiceChip(
    label: Text(label),
    selected: _history == history,
    onSelected: (_) => setState(() => _history = history),
    showCheckmark: false,
    side: BorderSide.none,
    selectedColor: Colors.white,
    backgroundColor: const Color(0xFF14765F),
    labelStyle: TextStyle(
      color: _history == history
          ? BagiPorsiColors.green
          : const Color(0xFFD2EAE2),
      fontWeight: FontWeight.w700,
      fontSize: 12,
    ),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  );

  Widget _card(FoodClaim claim) {
    final status = _store!.statusOf(claim);
    final active = status == ClaimStatus.active;
    final label = switch (status) {
      ClaimStatus.active => 'Diklaim · Belum diambil',
      ClaimStatus.collected => 'Sudah diambil',
      ClaimStatus.cancelled => 'Dibatalkan',
      ClaimStatus.expired => 'Kedaluwarsa',
    };
    final date = claim.expiresAt.toLocal();
    final deadline =
        '${date.day}/${date.month}/${date.year}, ${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
    return Card.outlined(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: BagiPorsiColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InfoPill(
                  label,
                  icon: active
                      ? Icons.schedule_rounded
                      : Icons.check_circle_outline,
                  color: active || status == ClaimStatus.collected
                      ? BagiPorsiColors.green
                      : BagiPorsiColors.muted,
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${claim.quantity} porsi',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BagiPorsiColors.ink,
                      ),
                    ),
                    if (active || status == ClaimStatus.collected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: BagiPorsiColors.mint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${claim.pointsEarned} poin',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: BagiPorsiColors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FoodPhoto(food: claim.food, size: 52, radius: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claim.food.foodName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claim.food.merchantName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total: ${claim.totalLabel}${claim.food.isFree ? '' : ' (Tunai)'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BagiPorsiColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (claim.userLocation != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: BagiPorsiColors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi pengguna · ${claim.userLocation!.label}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BagiPorsiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          claim.userLocation!.address,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: BagiPorsiColors.border),
            ),
            Container(
              decoration: BoxDecoration(
                color: BagiPorsiColors.mint,
                border: Border.all(color: const Color(0xFFBDDDCE)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KODE PENGAMBILAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .6,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          claim.code,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: BagiPorsiColors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          active ? 'Ketuk QR untuk melihat kode demo' : label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: BagiPorsiColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    IconButton.filledTonal(
                      tooltip: 'Lihat kode ${claim.code}',
                      onPressed: () => _showCode(claim),
                      icon: const Icon(Icons.qr_code_2_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: BagiPorsiColors.green,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: BagiPorsiColors.muted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Batas demo: $deadline',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: BagiPorsiColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            if (active) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _store!.busy ? null : () => _collect(claim),
                style: FilledButton.styleFrom(
                  backgroundColor: BagiPorsiColors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 19),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Selesaikan pengambilan',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final contact = OutlinedButton.icon(
                    onPressed: () => _contact(claim),
                    icon: const Icon(Icons.chat_bubble_outline, size: 17),
                    label: const Text('Hubungi penjual'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: BagiPorsiColors.green),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  final directions = OutlinedButton.icon(
                    onPressed: () => _directions(claim),
                    icon: const Icon(Icons.navigation_rounded, size: 17),
                    label: const Text('Petunjuk ambil'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: BagiPorsiColors.border),
                      foregroundColor: BagiPorsiColors.ink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  if (constraints.maxWidth /
                          (MediaQuery.textScalerOf(context).scale(14) / 14) <
                      300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        contact,
                        const SizedBox(height: 8),
                        directions,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: contact),
                      const SizedBox(width: 8),
                      Expanded(child: directions),
                    ],
                  );
                },
              ),
              TextButton(
                onPressed: _store!.busy ? null : () => _cancel(claim),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFBB5547),
                ),
                child: const Text('Batalkan klaim'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderStripes extends CustomPainter {
  const _HeaderStripes();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x07FFFFFF)
      ..strokeWidth = 10;
    for (double x = -size.height; x < size.width; x += 25) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeaderStripes oldDelegate) => false;
}
