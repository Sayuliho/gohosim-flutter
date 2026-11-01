import 'package:flutter/material.dart';

class AppTheme {
  // Palet wondr-inspired untuk GohoSIM
  static const Color primary    = Color(0xFF00B4A8); // Teal utama (seperti wondr)
  static const Color accent     = Color(0xFF00897B); // Teal gelap
  static const Color cta        = Color(0xFFFF7A2F); // Orange untuk tombol CTA
  static const Color success    = Color(0xFF2ECC71);
  static const Color warning    = Color(0xFFF39C12);
  static const Color danger     = Color(0xFFE74C3C);
  static const Color bgLight    = Color(0xFFF5F3E8); // Cream warm (seperti wondr)
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color textDark   = Color(0xFF1A2332);
  static const Color textGrey   = Color(0xFF6B7280);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: cta,
          surface: bgLight,
        ),
        scaffoldBackgroundColor: bgLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 3,
          shadowColor: Color(0x1A00B4A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: cta,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF9CA3AF),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          elevation: 8,
        ),
        fontFamily: 'Roboto',
      );
}
