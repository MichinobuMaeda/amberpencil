import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './models/app_state_model.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/app_info_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/email_verify_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/unknown_screen.dart';

class AppRoutePath {
  final String name;
  AppRoutePath(this.name);
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "");

    if (uri.pathSegments.isEmpty) {
      return AppRoutePath('');
    }

    if (uri.pathSegments.length == 1) {
      switch (uri.pathSegments[0]) {
        case 'loading':
          return AppRoutePath('loading');
        case 'info':
          return AppRoutePath('info');
        case 'signin':
          return AppRoutePath('signin');
        case 'verify':
          return AppRoutePath('verify');
        case 'prefs':
          return AppRoutePath('prefs');
      }
    }

    return AppRoutePath('unknown');
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: '/${configuration.name}');
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  AppStateModel? _appStateModel;
  AppRoutePath _current = AppRoutePath('loading');
  final List<MaterialPage> _pages = [buildPage(LoadingScreen(), 'loading')];

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration {
    return _current;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
      return Navigator(
        key: navigatorKey,
        pages: [..._pages],
        onPopPage: (route, result) {
          return false;
        },
      );
    });
  }

  void guard(AppStateModel appStateModel) {
    if (appStateModel.isLoading) {
      if (!(_appStateModel?.isLoading ?? true)) {
        _appStateModel = appStateModel;
        _current = AppRoutePath('loading');
        _pages.clear();
        _pages.add(buildPage(LoadingScreen(), _current.name));
        notifyListeners();
      }
    } else if (appStateModel.isGuest) {
      if (!(_appStateModel?.isGuest ?? false)) {
        _current = AppRoutePath('signin');
        _pages.clear();
        _pages.add(buildPage(SignInScreen(), _current.name));
        notifyListeners();
      }
    } else if (appStateModel.isPending) {
      if (!(_appStateModel?.isPending ?? false)) {
        _current = AppRoutePath('verify');
        _pages.clear();
        _pages.add(buildPage(EmailVerifyScreen(), _current.name));
        notifyListeners();
      }
    } else {
      if (!(_appStateModel?.isAuthenticated ?? false)) {
        _current = AppRoutePath('home');
        _pages.clear();
        _pages.add(buildPage(HomeScreen(), _current.name));
        notifyListeners();
      }
    }
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (_appStateModel?.isLoading ?? true) {
      if (configuration.name != 'loading') {
        configuration = AppRoutePath('loading');
      }
    } else if (_appStateModel?.isGuest ?? false) {
      if (!['signin', 'prefs', 'info'].contains(configuration.name)) {
        configuration = AppRoutePath('signin');
      }
    } else if (_appStateModel?.isPending ?? false) {
      if (!['verify', 'prefs', 'info'].contains(configuration.name)) {
        configuration = AppRoutePath('verify');
      }
    } else {
      if (['loading', 'signin', 'verify'].contains(configuration.name)) {
        configuration = AppRoutePath('home');
      }
    }

    if (_current == configuration) {
      return;
    }

    _current = configuration;
    late StatelessWidget screen;
    switch (configuration.name) {
      case '':
        screen = HomeScreen();
        break;
      case 'loading':
        screen = LoadingScreen();
        break;
      case 'info':
        screen = AppInfoScreen();
        break;
      case 'signin':
        screen = SignInScreen();
        break;
      case 'verify':
        screen = EmailVerifyScreen();
        break;
      case 'prefs':
        screen = PreferencesScreen();
        break;
      default:
        _current = AppRoutePath('unknown');
        screen = UnknownScreen();
    }

    _pages[0] = buildPage(screen, configuration.name);
  }
}

MaterialPage<dynamic> buildPage(Widget screen, String name) {
  return MaterialPage(
    key: ValueKey('page-$name'),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Amber pencil'),
      ),
      body: screen,
    ),
  );
}
