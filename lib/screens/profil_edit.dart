import 'package:flutter/material.dart';

import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';
import '../widgets/claim_scope.dart';
import 'profil_pages.dart';

class ProfilDetailPage extends StatelessWidget {
  const ProfilDetailPage({super.key, required this.profile});

  final UserProfileStore profile;

  void _openEdit(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ProfilEditPage(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: 156,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0A3828),
                                  BagiPorsiColors.deepGreen,
                                  BagiPorsiColors.green,
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -30,
                                  top: -20,
                                  child: Icon(
                                    Icons.eco_rounded,
                                    size: 160,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                                Positioned(
                                  left: -20,
                                  bottom: -30,
                                  child: Icon(
                                    Icons.spa_rounded,
                                    size: 130,
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                SafeArea(
                                  bottom: false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'Kembali',
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -42,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B9085),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 54),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              profile.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: BagiPorsiColors.ink,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: _ProfileStatItem(
                                    value: '0',
                                    label: 'suka',
                                  ),
                                ),
                                Expanded(
                                  child: _ProfileStatItem(
                                    value: '0',
                                    label: 'pengikut',
                                  ),
                                ),
                                Expanded(
                                  child: _ProfileStatItem(
                                    value: '0',
                                    label: 'mengikuti',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _openEdit(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B14F),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: const Text(
                                  'Ubah profil',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const _ProfileInspirationIllustration(),
                            const SizedBox(height: 24),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Petualangan makananmu bisa menginspirasi orang lain',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.3,
                                  fontWeight: FontWeight.w800,
                                  color: BagiPorsiColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tulis ulasan dan pandu orang lain untuk dapatkan penemuan lezat!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: BagiPorsiColors.muted,
                              ),
                            ),
                            const SizedBox(height: 32),
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
      },
    );
  }
}

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: BagiPorsiColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: BagiPorsiColors.muted),
        ),
      ],
    );
  }
}

class _ProfileInspirationIllustration extends StatelessWidget {
  const _ProfileInspirationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00B14F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: Color(0xFFB9F0CD),
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: BagiPorsiColors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD43B)),
                  Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD43B)),
                  Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD43B)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 34,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3A661),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 44,
                  height: 52,
                  decoration: BoxDecoration(
                    color: BagiPorsiColors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            child: Container(
              width: 190,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF7B6053),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilEditPage extends StatefulWidget {
  const ProfilEditPage({super.key, required this.profile});

  final UserProfileStore profile;

  @override
  State<ProfilEditPage> createState() => _ProfilEditPageState();
}

class _ProfilEditPageState extends State<ProfilEditPage> {
  final _form = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _phoneController = TextEditingController(
    text: widget.profile.phone,
  );
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late String? _selectedGender = widget.profile.gender;

  static const _genders = ['Perempuan', 'Laki-laki', 'Tidak ingin menyebutkan'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickGender() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Apa jenis kelaminmu?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BagiPorsiColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ini akan membantu kami menyesuaikan dan meningkatkan pengalaman pengguna.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: BagiPorsiColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              for (final option in _genders)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(sheetContext, option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: BagiPorsiColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedGender == option
                                  ? BagiPorsiColors.green
                                  : const Color(0xFFBDC3C7),
                              width: _selectedGender == option ? 6 : 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Untuk alasan keamanan, kami dapat melakukan pengecekan secara berkala terkait informasi yang kamu berikan saat ini dengan informasi yang tersimpan pada sistem kami',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: BagiPorsiColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null && mounted) {
      setState(() {
        _selectedGender = chosen;
      });
    }
  }

  void _save() {
    if (_form.currentState!.validate()) {
      widget.profile.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _roundedInputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BagiPorsiColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BagiPorsiColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: BagiPorsiColors.muted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final store = ClaimScope.maybeOf(context)?.store;
    final points = store?.points ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Tutup',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, size: 26),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2B9085),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 17,
                                color: BagiPorsiColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => PoinKamuPage(store: store),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5A623),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '$points Poin BagiPorsi',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BagiPorsiColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: BagiPorsiColors.ink,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _fieldLabel('Nama lengkap'),
                    TextFormField(
                      key: const ValueKey('profile-name-field'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _roundedInputDecoration(
                        hintText: 'Masukkan nama lengkap',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama tidak boleh kosong.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel('Nomor ponsel'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: BagiPorsiColors.border),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+62',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: BagiPorsiColors.ink,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: BagiPorsiColors.muted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey('profile-phone-field'),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _roundedInputDecoration(
                              hintText: '812xxxxxxx',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel('Email'),
                    TextFormField(
                      key: const ValueKey('profile-email-field'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _roundedInputDecoration(
                        hintText: 'nama@email.com',
                        suffixIcon: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00B14F),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel('Jenis kelamin'),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: BagiPorsiColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: const ValueKey('profile-gender-field'),
                        onTap: _pickGender,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedGender ??
                                      'Silakan pilih jenis kelamin',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _selectedGender == null
                                        ? BagiPorsiColors.muted
                                        : BagiPorsiColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: BagiPorsiColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: BagiPorsiColors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Simpan perubahan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
