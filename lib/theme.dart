import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

Flavor flavor = catppuccin.mocha;

ThemeData catppuccinTheme(Flavor flavor) {
  Color primaryColor = flavor.mauve;
  Color secondaryColor = flavor.pink;
  return ThemeData(
    useMaterial3: true,
    appBarTheme: AppBarTheme(
        elevation: 0,
        titleTextStyle: TextStyle(
            color: flavor.text, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: flavor.crust,
        foregroundColor: flavor.mantle),
    colorScheme: ColorScheme(
      surface: flavor.base,
      brightness: Brightness.light,
      error: flavor.surface2,
      onSurface: flavor.text,
      onError: flavor.red,
      onPrimary: primaryColor,
      onSecondary: secondaryColor,
      primary: flavor.crust,
      secondary: flavor.mantle,
    ),
    textTheme: const TextTheme().apply(
      bodyColor: flavor.text,
      displayColor: primaryColor,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
    ),
  );
}
