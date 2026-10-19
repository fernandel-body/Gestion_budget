import 'package:flutter/material.dart';

/// Identité visuelle de Gestion Budget.
/// Couleurs inspirées du drapeau malgache, avec un sens :
/// vert = ce qui rentre et ce qui reste, rouge = ce qui est dépensé.
class AppColors {
  static const rice = Color(0xFF0B5D3B); // vert rizière (couleur principale)
  static const riceSoft = Color(0xFFDDEBE2); // vert très clair (sélection)
  static const earth = Color(0xFFC8372D); // rouge (dépenses, alertes)
  static const paper = Color(0xFFF4F6F2); // fond de l'application
  static const ink = Color(0xFF16201A); // texte
  static const line = Color(0xFFDCE2DB); // traits fins
  static const muted = Color(0xFF5E6B63); // texte secondaire
}

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.rice,
      onPrimary: Colors.white,
      primaryContainer: AppColors.riceSoft,
      onPrimaryContainer: AppColors.rice,
      secondary: AppColors.earth,
      onSecondary: Colors.white,
      error: AppColors.earth,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final applied = base.textTheme
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
    final text = applied.copyWith(
      titleLarge: applied.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: applied.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: applied.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: applied.bodySmall?.copyWith(color: AppColors.muted),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(AppColors.line),
        enabledBorder: _border(AppColors.line),
        focusedBorder: _border(AppColors.rice, width: 1.8),
        errorBorder: _border(AppColors.earth),
        focusedErrorBorder: _border(AppColors.earth, width: 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.rice,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.rice,
        foregroundColor: Colors.white,
        elevation: 2,
        extendedTextStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.riceSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.rice : AppColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.rice : AppColors.muted,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.riceSoft,
        side: const BorderSide(color: AppColors.line),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
