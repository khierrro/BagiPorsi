import 'package:flutter/material.dart';

import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key, required this.profile});

  final UserProfileStore profile;

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.profile.location);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.profile.updateLocation(_controller.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BagiPorsiColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Lokasi kamu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  onPressed: _save,
                  child: const Text('Simpan lokasi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
