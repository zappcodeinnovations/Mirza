import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// ===================================================
  /// PORTAL COLORS (MATCHED TO MIRZA PORTAL UI)
  /// ===================================================

  /// Main background
  static const Color darkBg = Color(0xFFF1F4EF);

  /// Card / surface color
  static const Color darkSurface = Color(0xFFFCFDFB);

  /// Borders / dividers
  static const Color darkAccent = Color(0xFFD9E1D6);

  /// Primary Olive Green
  static const Color neonPurple = Color(0xFF5F7D4D);

  /// Soft Red / Notification
  static const Color neonPink = Color(0xFFE85B5B);

  /// Warm Light Olive
  static const Color neonOrange = Color(0xFF8EA27B);

  /// Light Gray
  static const Color neonBlue = Color(0xFF5C6672);

  /// Main Active Green
  static const Color neonGreen = Color(0xFF6C8756);

  /// ===================================================
  /// GRADIENTS
  /// ===================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C8756), Color(0xFF5F7D4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [Color(0xFF6C8756), Color(0xFF8EA27B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangePinkGradient = LinearGradient(
    colors: [Color(0xFF8EA27B), Color(0xFFA8B89A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ===================================================
  /// TEXT THEME
  /// ===================================================

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        color: const Color(0xFF30432A),
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),

      headlineMedium: GoogleFonts.inter(
        color: const Color(0xFF30432A),
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: GoogleFonts.inter(
        color: const Color(0xFF223025),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: GoogleFonts.inter(
        color: const Color(0xFF36413A),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      bodyMedium: GoogleFonts.inter(
        color: const Color(0xFF55605B),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),

      labelLarge: GoogleFonts.inter(
        color: const Color(0xFF223025),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// ===================================================
  /// LIGHT DASHBOARD THEME
  /// ===================================================

  static ThemeData get darkTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      /// SCAFFOLD
      scaffoldBackgroundColor: darkBg,

      /// CARD
      cardColor: darkSurface,

      /// COLOR SCHEME
      colorScheme: ColorScheme.light(
        primary: neonGreen,
        secondary: neonPurple,
        surface: darkSurface,
        background: darkBg,
        error: neonPink,

        onPrimary: Colors.white,
        onSecondary: Colors.white,

        onSurface: const Color(0xFF223025),
      ),

      /// DIVIDER
      dividerColor: darkAccent,

      /// TEXT THEME
      textTheme: _buildTextTheme(base.textTheme),

      /// ===================================================
      /// APPBAR
      /// ===================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: IconThemeData(color: Color(0xFF223025)),

        titleTextStyle: TextStyle(
          color: Color(0xFF223025),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      /// ===================================================
      /// CARD THEME
      /// ===================================================
      cardTheme: CardThemeData(
        color: const Color(0xFFFCFDFB),

        elevation: 0,

        shadowColor: const Color(0x1F30432A),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),

          side: const BorderSide(color: Color(0xFFC8D3C5), width: 1),
        ),
      ),

      /// ===================================================
      /// DIALOG
      /// ===================================================
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFCFDFB),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),

          side: const BorderSide(color: darkAccent),
        ),
      ),

      /// ===================================================
      /// INPUT THEME
      /// ===================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: Colors.white,
        // fillColor: const Color(0xFFFCFDFB),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: darkAccent),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: darkAccent),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: neonGreen, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: neonPink),
        ),

        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF809084),
          fontSize: 14,
        ),

        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF55605B),
          fontSize: 14,
        ),
      ),

      /// ===================================================
      /// BUTTONS
      /// ===================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: neonGreen,

          foregroundColor: Colors.white,

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      /// ===================================================
      /// BOTTOM NAVIGATION
      /// ===================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,

        selectedItemColor: neonGreen,

        unselectedItemColor: Color(0xFF73807A),

        type: BottomNavigationBarType.fixed,

        elevation: 8,
      ),
    );
  }
}
