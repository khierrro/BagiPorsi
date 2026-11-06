import 'package:flutter/material.dart';

import '../design/bagi_porsi_theme.dart';

/// Kolom pencarian bersama untuk Beranda, Peta, dan Chat.
///
/// Di atas latar berwarna (mis. header hijau) cukup dengan isian putih.
/// Di atas latar putih, set [onWhiteBackground] agar kolom diberi outline
/// dan bayangan tipis sehingga tetap terlihat.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.emptyTrailing,
    this.onWhiteBackground = false,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final String hintText;

  /// Tooltip / label aksesibilitas tombol hapus.
  final String clearTooltip;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Dipanggil setelah teks dihapus lewat tombol silang.
  final VoidCallback? onClear;

  /// Widget yang tampil di ujung kanan saat kolom kosong (opsional).
  final Widget? emptyTrailing;

  /// Tambahkan outline dan bayangan untuk latar putih.
  final bool onWhiteBackground;
  final TextInputAction textInputAction;

  static const _radius = 18.0;
  static const _iconColor = Color(0xFF4B5550);

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: onWhiteBackground
          ? const BorderSide(color: BagiPorsiColors.border)
          : BorderSide.none,
    );

    final field = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) => TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        style: const TextStyle(color: BagiPorsiColors.ink, fontSize: 16),
        cursorColor: BagiPorsiColors.green,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF858D89), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _iconColor),
          suffixIcon: value.text.isEmpty
              ? emptyTrailing
              : IconButton(
                  tooltip: clearTooltip,
                  icon: const Icon(Icons.close, color: _iconColor),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: onWhiteBackground
                  ? BagiPorsiColors.green
                  : const Color(0xFFB5D7CB),
              width: onWhiteBackground ? 1.5 : 1,
            ),
          ),
        ),
      ),
    );

    if (!onWhiteBackground) return field;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: field,
    );
  }
}
