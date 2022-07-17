import 'package:flutter/material.dart';

const colorSchemeSeed = Colors.amber;

final lightTheme = ThemeData(
  colorSchemeSeed: colorSchemeSeed,
  brightness: Brightness.light,
  useMaterial3: true,
);

final darkTheme = ThemeData(
  colorSchemeSeed: colorSchemeSeed,
  brightness: Brightness.dark,
  useMaterial3: true,
);

ButtonStyle filledButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
      primary: Theme.of(context).colorScheme.primary,
      onPrimary: Theme.of(context).colorScheme.onPrimary,
    );

Color listItemColor(BuildContext context, int index) => index.isOdd
    ? Theme.of(context).colorScheme.background
    : Theme.of(context).colorScheme.secondary.withAlpha(32);
