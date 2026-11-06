import 'package:flutter/material.dart';

import '../data/user_profile_store.dart';
import '../design/bagi_porsi_theme.dart';

class ProfilEditPage extends StatefulWidget {
  const ProfilEditPage({super.key, required this.profile});

  final UserProfileStore profile;

  @override
  State<ProfilEditPage> createState() => _ProfilEditPageState();
}

class _ProfilEditPageState extends State<ProfilEditPage> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.profile.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) {
      widget.profile.updateName(_controller.text.trim());
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
          'Edit profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nama yang tampil di profilmu.',
                  style: TextStyle(color: BagiPorsiColors.muted),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  maxLength: 50,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama tidak boleh kosong.'
                      : null,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Simpan perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
