import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.brown,
  errorColor: Colors.red,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.amber,
  errorColor: Colors.pinkAccent,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
);

const fontFamilySansSerif = 'NotoSansJP';
const fontFamilyMonoSpace = 'RobotoMono';

const double fontSizeBody = 16.0;

const double fontSizeH1 = fontSizeBody * 2.4;
const double fontSizeH2 = fontSizeBody * 1.6;
const double fontSizeH3 = fontSizeBody * 1.3;
const double fontSizeH4 = fontSizeBody * 1.1;
const double fontSizeH5 = fontSizeBody * 1.05;
const double fontSizeH6 = fontSizeBody * 1.0;

const TextTheme textTheme = TextTheme(
  headline1: TextStyle(fontSize: fontSizeH1),
  headline2: TextStyle(fontSize: fontSizeH2),
  headline3: TextStyle(fontSize: fontSizeH3),
  headline4: TextStyle(fontSize: fontSizeH4),
  headline5: TextStyle(fontSize: fontSizeH5),
  headline6: TextStyle(fontSize: fontSizeH6),
  subtitle1: TextStyle(fontSize: fontSizeH5),
  subtitle2: TextStyle(fontSize: fontSizeBody),
  bodyText1: TextStyle(fontSize: fontSizeH5),
  bodyText2: TextStyle(fontSize: fontSizeBody),
  button: TextStyle(fontSize: fontSizeBody),
  caption: TextStyle(fontSize: fontSizeBody),
  overline: TextStyle(fontSize: fontSizeBody * 0.9),
);

final buttonMinimumSize = MaterialStateProperty.all<Size>(
  const Size(fontSizeBody * 8, fontSizeBody * 3),
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

Color secondaryColor = Colors.blueGrey;
Color errorColor(BuildContext context) => Theme.of(context).colorScheme.error;

MaterialStateProperty<Color> secondaryMaterialStateColor =
    MaterialStateProperty.all<Color>(secondaryColor);
MaterialStateProperty<Color> errorMaterialStateColor(BuildContext context) =>
    MaterialStateProperty.all<Color>(errorColor(context));

final secondaryElevatedButtonStyle = ButtonStyle(
  backgroundColor: secondaryMaterialStateColor,
);

final secondaryOutlinedButtonStyle = ButtonStyle(
  foregroundColor: secondaryMaterialStateColor,
);

ButtonStyle errorElevatedButtonStyle(BuildContext context) =>
    ButtonStyle(backgroundColor: errorMaterialStateColor(context));

ButtonStyle errorOutlinedButtonStyle(BuildContext context) =>
    ButtonStyle(foregroundColor: errorMaterialStateColor(context));

final MarkdownStyleSheet markdownStyleSheet = MarkdownStyleSheet(
  h2: const TextStyle(fontSize: fontSizeH2, height: 1.8),
  h3: const TextStyle(fontSize: fontSizeH3, height: 1.8),
  h4: const TextStyle(fontSize: fontSizeH4, height: 1.8),
  h5: const TextStyle(fontSize: fontSizeH5, height: 1.8),
  h6: const TextStyle(fontSize: fontSizeH6, height: 1.8),
  p: const TextStyle(fontSize: fontSizeBody, height: 1.8),
  code: const TextStyle(
    fontSize: fontSizeBody,
    height: 1.2,
    fontFamily: fontFamilyMonoSpace,
  ),
);
