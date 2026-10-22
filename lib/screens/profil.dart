import 'package:flutter/material.dart';
import '../design/bagi_porsi_theme.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 47,
                backgroundColor: BagiPorsiColors.mint,
                child: Icon(
                  Icons.person_outline,
                  size: 48,
                  color: BagiPorsiColors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nama Pengguna',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BagiPorsiColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Mahasiswa / Pengguna Aktif',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BagiPorsiColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 38),
            const Text(
              'Dampak baikmu',
              style: TextStyle(
                color: BagiPorsiColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                color: BagiPorsiColors.lime,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: _ImpactStat(
                      label: 'Porsi Diselamatkan',
                      value: '12',
                      icon: Icons.restaurant_outlined,
                    ),
                  ),
                  SizedBox(
                    height: 92,
                    child: VerticalDivider(color: Color(0xFFBED9C8)),
                  ),
                  Expanded(
                    child: _ImpactStat(
                      label: 'Uang Dihemat',
                      value: 'Rp 150k',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 38),
            _profileAction(
              icon: Icons.history,
              title: 'Riwayat Klaim Makanan',
            ),
            const SizedBox(height: 14),
            _profileAction(
              icon: Icons.favorite_border,
              title: 'Restoran Favorit',
            ),
            const SizedBox(height: 58),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0ED),
                foregroundColor: const Color(0xFFB83425),
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text(
                'Keluar Akun',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileAction({required IconData icon, required String title}) {
    return ListTile(
      tileColor: BagiPorsiColors.canvas,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: BagiPorsiColors.green),
      title: Text(
        title,
        style: const TextStyle(
          color: BagiPorsiColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: BagiPorsiColors.muted),
      onTap: () {},
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: BagiPorsiColors.green, size: 27),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: BagiPorsiColors.green,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: BagiPorsiColors.ink,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
