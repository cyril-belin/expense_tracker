import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
// AppTheme — Bold Material You design system.
// Rich seed colour, custom TextTheme sizes, NavigationBar,
// Dialog, SnackBar and elevated card/button styles.
// ─────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // Primary brand colour — deep indigo-violet.
  static const _seed = Color(0xFF5C51F3);

  // ── Shared helpers ────────────────────────────────────────

  static CardThemeData _cardTheme() => CardThemeData(
    elevation: 0,
    color: Colors.transparent, // screens set their own surface colour
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.zero,
  );

  static InputDecorationTheme _inputTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        floatingLabelStyle: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      );

  static FilledButtonThemeData _filledButtonTheme() => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        height: 70,
        elevation: 8,
        shadowColor: cs.shadow.withValues(alpha: 0.1),
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          );
        }),
      );

  static DialogThemeData _dialogTheme(ColorScheme cs) => DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    backgroundColor: cs.surfaceContainerHigh,
    elevation: 8,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    ),
    contentTextStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
  );

  static SnackBarThemeData _snackBarTheme(ColorScheme cs) => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: cs.inverseSurface,
    contentTextStyle: TextStyle(color: cs.onInverseSurface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    actionTextColor: cs.inversePrimary,
  );

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: cs.onSurface,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: cs.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ),
  );

  // ── Light theme ───────────────────────────────────────────

  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
    ).copyWith(
      surface: const Color(0xFFFFFFFF),
      surfaceContainerLowest: const Color(0xFFF6F8FC),
      surfaceContainerLow: const Color(0xFFEEF1F7),
      surfaceContainer: const Color(0xFFE5E9F0),
      surfaceContainerHigh: const Color(0xFFDCE1EB),
      surfaceContainerHighest: const Color(0xFFCFD5E2),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surfaceContainerLowest,
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledButtonTheme(),
      navigationBarTheme: _navBarTheme(cs),
      dialogTheme: _dialogTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      textTheme: _textTheme(cs),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────

  static ThemeData get dark {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF14151F),
      surfaceContainerLowest: const Color(0xFF0C0D14),
      surfaceContainerLow: const Color(0xFF11121B),
      surfaceContainer: const Color(0xFF141520),
      surfaceContainerHigh: const Color(0xFF1D1F2D),
      surfaceContainerHighest: const Color(0xFF26283C),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surfaceContainerLowest,
      appBarTheme: _appBarTheme(cs),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledButtonTheme(),
      navigationBarTheme: _navBarTheme(cs),
      dialogTheme: _dialogTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      textTheme: _textTheme(cs),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
    );
  }

  // ── Custom text theme ─────────────────────────────────────

  static TextTheme _textTheme(ColorScheme cs) => TextTheme(
    // Used for big money totals
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: cs.onSurface,
    ),
    // Section amounts / headings
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: cs.onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: cs.onSurfaceVariant,
      letterSpacing: 0.3,
    ),
    bodyLarge: TextStyle(fontSize: 15, color: cs.onSurface),
    bodyMedium: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
    bodySmall: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: cs.onSurface,
    ),
  );
}
