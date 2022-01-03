import 'package:flutter/material.dart';

const MaterialColor primarySwatchLight = Colors.brown;
const MaterialColor primarySwatchDark = Colors.amber;
const Color colorSecondary = Colors.blueGrey;
const Color colorDanger = Colors.redAccent;
const Color colorActiveView = Colors.orangeAccent;

const fontFamilySansSerif = 'NotoSansJP';
const fontFamilyMonoSpace = 'RobotoMono';

const double fontSizeBody = 16.0;

const double maxContentBodyWidth = 960.0;
const double buttonWidth = fontSizeBody * 7.5;
const double buttonHeight = fontSizeBody * 3;

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

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: primarySwatchLight,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: primarySwatchDark,
  fontFamily: fontFamilySansSerif,
  textTheme: textTheme,
);
