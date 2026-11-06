import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class BagiPorsiColors {
  static const green = Color(0xFF006B50);
  static const deepGreen = Color(0xFF005747);
  static const ink = Color(0xFF183C32);
  static const mint = Color(0xFFEAF9F5);
  static const lime = Color(0xFFE6F3DA);
  static const canvas = Color(0xFFF7F8F7);
  static const border = Color(0xFFE6EAE8);
  static const muted = Color(0xFF717471);
  static const orange = Color(0xFFFF6D00);
}

abstract final class BagiPorsiTheme {
  static const fontFamily = 'Plus Jakarta Sans';
  static const fontFallback = <String>[
    'Inter',
    'Segoe UI',
    'SF Pro Display',
    'Roboto',
    'sans-serif',
  ];

  static ThemeData get data => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BagiPorsiColors.green,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        height: 1.25,
        color: BagiPorsiColors.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.25,
        color: BagiPorsiColors.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: BagiPorsiColors.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        letterSpacing: -0.1,
        height: 1.4,
        color: BagiPorsiColors.ink,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        letterSpacing: -0.05,
        height: 1.35,
        color: BagiPorsiColors.muted,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: BagiPorsiColors.muted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BagiPorsiColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BagiPorsiColors.green,
        side: const BorderSide(color: BagiPorsiColors.green),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BagiPorsiColors.green,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: BagiPorsiColors.green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      height: 78,
      indicatorColor: BagiPorsiColors.mint,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? BagiPorsiColors.green
              : BagiPorsiColors.muted,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? BagiPorsiColors.green : BagiPorsiColors.muted,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        );
      }),
    ),
  );
}
