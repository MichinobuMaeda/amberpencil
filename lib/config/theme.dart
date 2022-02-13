import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const FlexScheme themeColorScheme = FlexScheme.amber;

Color listOddEvenItemColor(BuildContext context) =>
    Theme.of(context).colorScheme.shadow.withOpacity(1 / 20);

const AssetImage logoAsset = AssetImage('images/logo.png');

const pageWidth = 720.0;
const columnWidth = 720.0;
const fieldWidth = 480.0;

bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 480.0;

const double baseFontSize = 16.0;
const double spacing = baseFontSize;

const fontFamilySansSerif = 'NotoSansJP';
const fontFamilyMonoSpace = 'RobotoMono';

const double fontSizeH1 = baseFontSize * 2.4;
const double fontSizeH2 = baseFontSize * 1.6;
const double fontSizeH3 = baseFontSize * 1.3;
const double fontSizeH4 = baseFontSize * 1.1;
const double fontSizeH5 = baseFontSize * 1.05;
const double fontSizeH6 = baseFontSize * 1.0;
const double fontSizeOverline = baseFontSize * 0.9;

const buttonMinimumSize = Size(baseFontSize * 8, baseFontSize * 3);

List<ThemeMode> supportedThemeModes = [
  ThemeMode.system,
  ThemeMode.light,
  ThemeMode.dark,
];

final buttonStyle = ButtonStyle(
  minimumSize: MaterialStateProperty.all<Size>(buttonMinimumSize),
);

const snackBarTheme = SnackBarThemeData(
  contentTextStyle: TextStyle(
    fontFamily: fontFamilySansSerif,
    fontSize: baseFontSize,
  ),
);

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
  overline: TextStyle(fontSize: fontSizeOverline),
);

MarkdownStyleSheet markdownStyleSheet(BuildContext context) =>
    MarkdownStyleSheet(
      h2: Theme.of(context).textTheme.headline2,
      h3: Theme.of(context).textTheme.headline3,
      h4: Theme.of(context).textTheme.headline4,
      h5: Theme.of(context).textTheme.headline5,
      h6: Theme.of(context).textTheme.headline6,
      p: Theme.of(context).textTheme.bodyText2,
      code: Theme.of(context).textTheme.bodyText2?.copyWith(
            height: 1.2,
            fontFamily: fontFamilyMonoSpace,
            color: Theme.of(context).colorScheme.secondary,
          ),
    );
