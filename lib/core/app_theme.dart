import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get midnightRoseTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0A12),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7B3F6E),
      onPrimary: Color(0xFFFFF5F0),
      secondary: Color(0xFFD4AF37),
      onSecondary: Color(0xFF1A0D12),
      tertiary: Color(0xFFE8B4B8),
      onTertiary: Color(0xFF1A0D12),
      surface: Color(0xFF181322),
      onSurface: Color(0xFFF5EEF0),
      surfaceContainerHighest: Color(0xFF241D30),
      onSurfaceVariant: Color(0xFFC8BFC4),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF1A0D12),
      outline: Color(0xFF3D3348),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF181322),
      foregroundColor: Color(0xFFF5EEF0),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF5EEF0),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFF5EEF0)),
      titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF5EEF0)),
      titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF5EEF0)),
      bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16, height: 1.5, color: Color(0xFFE8DEE2)),
      bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.5, color: Color(0xFFE8DEE2)),
      bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFFB8AEB4)),
      labelLarge: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF5EEF0)),
      labelSmall: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFB8AEB4)),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      color: const Color(0xFF1E182A),
      shadowColor: const Color(0xFF7B3F6E).withValues(alpha: 0.15),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: const Color(0xFF1A0D12),
        disabledBackgroundColor: const Color(0xFF3D3348),
        disabledForegroundColor: const Color(0xFF6A5E70),
        shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD4AF37),
        disabledForegroundColor: const Color(0xFF6A5E70),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD4AF37),
        disabledForegroundColor: const Color(0xFF6A5E70),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFFD4AF37),
      foregroundColor: const Color(0xFF1A0D12),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF241D30),
      hintStyle: const TextStyle(color: Color(0xFF6A5E70), fontFamily: 'Cairo'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3D3348)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: const Color(0xFF7B3F6E),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3D3348),
      thickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: const Color(0xFF241D30),
      contentTextStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFF5EEF0)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E182A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF5EEF0)),
      contentTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFFE8DEE2)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E182A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF241D30),
      selectedColor: const Color(0xFF7B3F6E),
      labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFFF5EEF0)),
      secondaryLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFFF5EEF0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: Color(0xFF3D3348)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFFD4AF37),
      inactiveTrackColor: Color(0xFF3D3348),
      thumbColor: Color(0xFFD4AF37),
      overlayColor: Color(0x29D4AF37),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFFD4AF37);
        return const Color(0xFF6A5E70);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFFD4AF37).withValues(alpha: 0.4);
        return const Color(0xFF3D3348);
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFD4AF37),
      circularTrackColor: Color(0xFF3D3348),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF181322),
      indicatorColor: const Color(0xFF7B3F6E).withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37));
        }
        return const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFF6A5E70));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFFD4AF37), size: 24);
        }
        return const IconThemeData(color: Color(0xFF6A5E70), size: 24);
      }),
    ),
  );

  static ThemeData get tealTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F6F0),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0D9488),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFD4AF37),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFF7B3F6E),
      onTertiary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFF0EDE8),
      onSurfaceVariant: Color(0xFF49454F),
      error: Color(0xFFDC362E),
      onError: Color(0xFFFFFFFF),
      outline: Color(0xFFCAC4D0),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF0D9488),
      foregroundColor: Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFFFF),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1C1B1F)),
      titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1C1B1F)),
      titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C1B1F)),
      bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16, height: 1.5, color: Color(0xFF1C1B1F)),
      bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.5, color: Color(0xFF1C1B1F)),
      bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFF49454F)),
      labelLarge: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1F)),
      labelSmall: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF49454F)),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFFFFFFFF),
      shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: const Color(0xFFFFFFFF),
        disabledBackgroundColor: const Color(0xFFE0DDD8),
        disabledForegroundColor: const Color(0xFF9E9B96),
        shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.3),
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0D9488),
        disabledForegroundColor: const Color(0xFF9E9B96),
        side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0D9488),
        disabledForegroundColor: const Color(0xFF9E9B96),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF0D9488),
      foregroundColor: const Color(0xFFFFFFFF),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      hintStyle: const TextStyle(color: Color(0xFF9E9B96), fontFamily: 'Cairo'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0DDD8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: const Color(0xFF0D9488),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0DDD8),
      thickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F)),
      contentTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF49454F)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF0EDE8),
      selectedColor: const Color(0xFF0D9488),
      labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF1C1B1F)),
      secondaryLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFFFFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF0D9488),
      circularTrackColor: Color(0xFFE0DDD8),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFF0D9488);
        return const Color(0xFF9E9B96);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFF0D9488).withValues(alpha: 0.4);
        return const Color(0xFFE0DDD8);
      }),
    ),
  );
}
