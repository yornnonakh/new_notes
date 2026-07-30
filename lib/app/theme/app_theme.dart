import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New specific color palette
  static const Color bodyColor = Color(0xFFF2F2F7);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textGrey = Color(0xFF8E8E93);
  static const Color folderYellow = Color(0xFFFFCC00);
  static const Color dividerColor = Color(0xFFE5E5EA);
  static const Color searchBarColor = Color(0xFFFFFFFF);
  static const Color hintColor = Color(0xFF8E8E93);

  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: folderYellow,
    scaffoldBackgroundColor: bodyColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: folderYellow,
      primary: folderYellow,
      surface: cardColor,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 0.5,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: folderYellow),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: const TextStyle(color: textPrimary),
      bodyMedium: const TextStyle(color: textSecondary),
    ),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: folderYellow,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: ColorScheme.fromSeed(
      seedColor: folderYellow,
      primary: folderYellow,
      brightness: Brightness.dark,
      surface: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: folderYellow),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
  );
}
