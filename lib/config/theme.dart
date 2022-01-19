import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const AssetImage logoAsset = AssetImage('images/logo.png');

const pageWidth = 720.0;
const columnWidth = 720.0;
const fieldWidth = 480.0;

const double baseFontSize = 16.0;
const double spacing = baseFontSize;

final ThemeData baseLightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.brown,
  errorColor: Colors.red,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.brown,
    contentTextStyle: TextStyle(
      fontFamily: fontFamilySansSerif,
      fontSize: baseFontSize,
      color: Colors.white,
    ),
  ),
);

final ThemeData lightTheme = baseLightTheme.copyWith(
  colorScheme: baseLightTheme.colorScheme.copyWith(
    secondary: Colors.blueGrey,
    onSecondary: baseLightTheme.colorScheme.onPrimary,
  ),
);

final ThemeData baseDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.amber,
  errorColor: Colors.pinkAccent,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.amber,
    contentTextStyle: TextStyle(
      fontFamily: fontFamilySansSerif,
      fontSize: baseFontSize,
      color: Colors.black,
    ),
  ),
);

final ThemeData darkTheme = baseDarkTheme.copyWith(
  colorScheme: baseDarkTheme.colorScheme.copyWith(
    secondary: Colors.cyan,
    onSecondary: baseLightTheme.colorScheme.onSurface,
  ),
);

const fontFamilySansSerif = 'NotoSansJP';
const fontFamilyMonoSpace = 'RobotoMono';

const double fontSizeH1 = baseFontSize * 2.4;
const double fontSizeH2 = baseFontSize * 1.6;
const double fontSizeH3 = baseFontSize * 1.3;
const double fontSizeH4 = baseFontSize * 1.1;
const double fontSizeH5 = baseFontSize * 1.05;
const double fontSizeH6 = baseFontSize * 1.0;

const TextTheme textTheme = TextTheme(
  headline1: TextStyle(fontSize: fontSizeH1),
  headline2: TextStyle(fontSize: fontSizeH2),
  headline3: TextStyle(fontSize: fontSizeH3),
  headline4: TextStyle(fontSize: fontSizeH4),
  headline5: TextStyle(fontSize: fontSizeH5),
  headline6: TextStyle(fontSize: fontSizeH6),
  subtitle1: TextStyle(fontSize: fontSizeH5),
  subtitle2: TextStyle(fontSize: baseFontSize),
  bodyText1: TextStyle(fontSize: fontSizeH5),
  bodyText2: TextStyle(fontSize: baseFontSize),
  button: TextStyle(fontSize: baseFontSize),
  caption: TextStyle(fontSize: baseFontSize),
  overline: TextStyle(fontSize: baseFontSize * 0.9),
);

final buttonMinimumSize = MaterialStateProperty.all<Size>(
  const Size(baseFontSize * 8, baseFontSize * 3),
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    minimumSize: buttonMinimumSize,
  ),
);

final outlinedButtonTheme = OutlinedButtonThemeData(
  style: ButtonStyle(
    minimumSize: buttonMinimumSize,
  ),
);

MarkdownStyleSheet markdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  return MarkdownStyleSheet(
    h2: theme.textTheme.headline2,
    h3: theme.textTheme.headline3,
    h4: theme.textTheme.headline4,
    h5: theme.textTheme.headline5,
    h6: theme.textTheme.headline6,
    p: theme.textTheme.bodyText2,
    code: theme.textTheme.bodyText2?.copyWith(
      height: 1.2,
      fontFamily: fontFamilyMonoSpace,
      color: theme.colorScheme.secondary,
    ),
  );
}

List<ThemeMode> supportedThemeModes = [
  ThemeMode.system,
  ThemeMode.light,
  ThemeMode.dark,
];
