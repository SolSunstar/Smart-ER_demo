import 'package:material_ui/material_ui.dart';

/// Colours inspired by the Smart Commute app: deep green bars,
/// white cards on a light grey background, and a strong red reserved
/// for Emergency Ride Home so it always stands out.
class AppColors {
  static const green = Color(0xFF1E7B1E);
  static const greenDark = Color(0xFF145A14);
  static const background = Color(0xFFF2F3F5);
  static const emergency = Color(0xFFD32F2F);
  static const emergencyDark = Color(0xFFB71C1C);
  static const bluetooth = Color(0xFF1565C0);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    error: AppColors.emergency,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        side: const BorderSide(color: AppColors.green),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF0F0F0),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      isDense: true,
    ),
  );
}
