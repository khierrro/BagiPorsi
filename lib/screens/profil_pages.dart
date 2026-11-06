import 'package:flutter/material.dart';

import '../data/claim_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/claim_scope.dart';
import '../widgets/feature_widgets.dart';

class PoinKamuPage extends StatelessWidget {
  const PoinKamuPage({super.key, this.store});

  final ClaimStore? store;

  @override
  Widget build(BuildContext context) {
    final activeStore = store ?? ClaimScope.maybeOf(context)?.store;
    final points = activeStore?.points ?? 0;
    final level = activeStore?.levelTitle ?? 'Pemula Pangan';
    final collected = activeStore?.collected ?? const <FoodClaim>[];

    final levels = [
      (
        title: 'Pemula Pangan',
        range: '0 - 20 poin',
        desc: 'Langkah awal menyelamatkan porsi baik di sekitarmu.',
        active: points < 30,
      ),
      (
        title: 'Penyelamat Porsi',
        range: '30 - 90 poin',
        desc: 'Konsisten mengurangi makanan berlebih bersama toko lokal.',
        active: points >= 30 && points < 100,
      ),
      (
        title: 'Pahlawan Zero Hunger',
        range: '100+ poin',
        desc: 'Kontributor utama gerakan berbagi pangan tanpa limbah.',
        active: points >= 100,
      ),
    ];

    return Scaffold(
      backgroundColor: BagiPorsiColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Poin Kamu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: BagiPorsiColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: BagiPorsiColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: BagiPorsiColors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$points poin',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: BagiPorsiColors.mint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Level: $level',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: BagiPorsiColors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        points == 0
                            ? 'Belum ada poin terkumpul. Dapatkan +10 poin setiap 1 porsi makanan selesai diambil.'
                            : 'Kamu mendapatkan +10 poin untuk setiap porsi makanan yang selesai diambil.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tingkatan Level Kebaikan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BagiPorsiColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                for (final item in levels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.active
                              ? BagiPorsiColors.green
                              : BagiPorsiColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: BagiPorsiColors.ink,
                                ),
                              ),
                              Text(
                                '(${item.range})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BagiPorsiColors.muted,
                                ),
                              ),
                              if (item.active)
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
                                    'Saat ini',
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
                            item.desc,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: BagiPorsiColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Riwayat Perolehan Poin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BagiPorsiColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                if (collected.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BagiPorsiColors.border),
                    ),
                    child: const Text(
                      'Belum ada riwayat poin. Selesaikan pengambilan makanan pertamamu untuk mulai mengumpulkan poin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: BagiPorsiColors.muted,
                      ),
                    ),
                  )
                else
                  for (final claim in collected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BagiPorsiColors.border),
                        ),
                        child: Row(
                          children: [
                            FoodPhoto(food: claim.food, size: 46, radius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    claim.food.foodName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: BagiPorsiColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${claim.quantity} porsi · ${claim.food.merchantName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: BagiPorsiColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: BagiPorsiColors.mint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '+${claim.pointsEarned} poin',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: BagiPorsiColors.green,
                                ),
                              ),
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
    );
  }
}

class DampakBaikPage extends StatelessWidget {
  const DampakBaikPage({super.key, this.store});

  final ClaimStore? store;

  @override
  Widget build(BuildContext context) {
    final activeStore = store ?? ClaimScope.maybeOf(context)?.store;
    final rescued = activeStore?.rescuedPortions ?? 0;
    final savings = activeStore?.totalSavingsLabel ?? 'Rp0';
    final collected = activeStore?.collected ?? const <FoodClaim>[];

    return Scaffold(
      backgroundColor: BagiPorsiColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Dampak Baikmu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BagiPorsiColors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: BagiPorsiColors.lime,
                        child: Icon(
                          Icons.eco_outlined,
                          color: BagiPorsiColors.green,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Dampak baikmu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rescued == 0
                            ? 'Setiap porsi berarti. Porsi pertamamu akan menjadi awal dampak baik di sini.'
                            : 'Terima kasih! Kamu telah membantu menyelamatkan $rescued porsi makanan layak konsumsi.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFFD2EAE2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final first = _ImpactCard(
                      value: '$rescued',
                      label: 'Porsi diselamatkan',
                      icon: Icons.restaurant_rounded,
                    );
                    final second = _ImpactCard(
                      value: savings,
                      label: 'Total penghematan',
                      icon: Icons.savings_outlined,
                    );
                    if (constraints.maxWidth < 340) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [first, const SizedBox(height: 12), second],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: first),
                        const SizedBox(width: 12),
                        Expanded(child: second),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BagiPorsiColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SDG 2 · Zero Hunger',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kurangi makanan layak konsumsi yang terbuang dan bantu pemerataan akses pangan hemat di sekitarmu.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (collected.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Porsi yang Telah Diselamatkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: BagiPorsiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final claim in collected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BagiPorsiColors.border),
                        ),
                        child: Row(
                          children: [
                            FoodPhoto(food: claim.food, size: 46, radius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    claim.food.foodName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: BagiPorsiColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${claim.quantity} porsi · ${claim.food.merchantName}',
                                    style: const TextStyle(
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
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BagiPorsiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BagiPorsiColors.green, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: BagiPorsiColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: BagiPorsiColors.muted),
          ),
        ],
      ),
    );
  }
}

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  static const _faqs = [
    (
      question: 'Bagaimana cara mengambil makanan?',
      answer: 'Pilih makanan di Beranda atau Peta, buka detailnya, tentukan jumlah porsi, lalu ketuk Lanjut ambil. Tunjukkan kode pengambilan di toko dan tekan Selesaikan pengambilan.',
    ),
    (
      question: 'Apakah semua makanan gratis?',
      answer: 'Ada pilihan gratis dan pilihan dengan harga hemat. Harga setiap porsi tertera jelas pada kartu makanan.',
    ),
    (
      question: 'Bagaimana cara mendapatkan poin kebaikan?',
      answer: 'Setiap 1 porsi makanan yang selesai kamu ambil memberikan +10 poin kebaikan secara otomatis.',
    ),
    (
      question: 'Bagaimana jika saya berhalangan mengambil makanan?',
      answer: 'Kamu dapat membatalkan klaim aktif dari halaman Klaim Saya agar stok porsi kembali tersedia untuk pengguna lain.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BagiPorsiColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pertanyaan yang Sering Diajukan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BagiPorsiColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in _faqs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BagiPorsiColors.border),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: BagiPorsiColors.ink,
                          ),
                        ),
                        children: [
                          Text(
                            item.answer,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: BagiPorsiColors.muted,
                            ),
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
    );
  }
}

class TentangBagiPorsiPage extends StatelessWidget {
  const TentangBagiPorsiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BagiPorsiColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Tentang BagiPorsi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: BagiPorsiColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: BagiPorsiColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_outlined,
                          color: BagiPorsiColors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Porsi baik untuk semua',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BagiPorsi mempertemukan makanan layak konsumsi yang masih tersedia dari toko, bakery, dan warung lokal dengan masyarakat di sekitarnya secara gratis maupun harga hemat.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: BagiPorsiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: BagiPorsiColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Komitmen Berkelanjutan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: BagiPorsiColors.ink,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Mendukung tujuan pembangunan berkelanjutan SDG 2 (Zero Hunger) dan mengurangi pemborosan pangan harian melalui kolaborasi komunitas.',
                        style: TextStyle(
                          fontSize: 13,
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
        ),
      ),
    );
  }
}
