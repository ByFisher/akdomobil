import 'package:flutter/material.dart';

@immutable
class AkdoThemeTokens extends ThemeExtension<AkdoThemeTokens> {
  const AkdoThemeTokens({
    required this.groupedBackground,
    required this.surface,
    required this.separator,
    required this.secondaryText,
    required this.cornerRadius,
  });

  final Color groupedBackground;
  final Color surface;
  final Color separator;
  final Color secondaryText;
  final double cornerRadius;

  @override
  AkdoThemeTokens copyWith({
    Color? groupedBackground,
    Color? surface,
    Color? separator,
    Color? secondaryText,
    double? cornerRadius,
  }) {
    return AkdoThemeTokens(
      groupedBackground: groupedBackground ?? this.groupedBackground,
      surface: surface ?? this.surface,
      separator: separator ?? this.separator,
      secondaryText: secondaryText ?? this.secondaryText,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  AkdoThemeTokens lerp(
    covariant ThemeExtension<AkdoThemeTokens>? other,
    double t,
  ) {
    if (other is! AkdoThemeTokens) return this;
    return AkdoThemeTokens(
      groupedBackground: Color.lerp(
        groupedBackground,
        other.groupedBackground,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      cornerRadius: cornerRadius + (other.cornerRadius - cornerRadius) * t,
    );
  }
}

abstract final class AkdoAppTheme {
  static const accent = Color(0xFF09090B);
  static const label = Color(0xFF09090B);
  static const groupedBackground = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const separator = Color(0xFFE4E4E7);

  static ThemeData get light {
    const tokens = AkdoThemeTokens(
      groupedBackground: groupedBackground,
      surface: surface,
      separator: separator,
      secondaryText: Color(0xFF71717A),
      cornerRadius: 10,
    );
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(primary: accent);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.cornerRadius),
      borderSide: const BorderSide(color: separator),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: groupedBackground,
      extensions: const <ThemeExtension<dynamic>>[tokens],
      appBarTheme: const AppBarTheme(
        backgroundColor: groupedBackground,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 50),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.cornerRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: separator,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
