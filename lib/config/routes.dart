import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/app_info_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/email_verify_screen.dart';
import '../screens/preferences_screen.dart';
import '../screens/unknown_screen.dart';

// home: '/' <--> level1: '/name' <--> level2: '/name/id'

const homeRouteName = '';
const loadingRouteName = 'loading';
const signinRouteName = 'signin';
const verifyRouteName = 'verify';

const unknownRouteName = 'unknown';

// routes hide back button.
const List<String> topRouteNames = [
  homeRouteName,
  loadingRouteName,
  signinRouteName,
  verifyRouteName,
];

const infoRouteName = 'info';
const prefsRouteName = 'prefs';

const List<String> level1RouteNames = [
  loadingRouteName,
  signinRouteName,
  verifyRouteName,
  prefsRouteName,
  infoRouteName,
];

const List<String> level2RouteNames = [];

const List<String> routeNames = [
  homeRouteName,
  ...level1RouteNames,
  ...level2RouteNames,
];

Map<String, StatelessWidget> routeNameMap = {};

void initializeRouteNameMap() {
  routeNameMap[homeRouteName] = const HomeScreen();
  routeNameMap[loadingRouteName] = const LoadingScreen();
  routeNameMap[signinRouteName] = const SignInScreen();
  routeNameMap[verifyRouteName] = const EmailVerifyScreen();
  routeNameMap[prefsRouteName] = const PreferencesScreen();
  routeNameMap[infoRouteName] = const AppInfoScreen();
  routeNameMap[unknownRouteName] = const UnknownScreen();
}
