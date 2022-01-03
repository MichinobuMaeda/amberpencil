import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'models/app_info.dart';
import 'models/app_route.dart';
import 'models/theme_mode_provider.dart';
import 'models/app_state_provider.dart';
import 'services/sys_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'screens/base_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/app_info_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/email_verify_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/unknown_screen.dart';
import 'utils/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // assets
  final AppInfo appInfo = AppInfo.fromJson(
    await rootBundle.loadString('assets/app_info.json'),
  );

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await useFirebaseEmulators(
    appInfo.version,
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
    firebase_storage.FirebaseStorage.instance,
  );

  // Service providers
  SysService sysService = SysService(
    FirebaseFirestore.instance,
  );
  AuthService authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
  AccountsService accountsService = AccountsService(
    FirebaseFirestore.instance,
  );

  runApp(
    MultiProvider(
      // Change notifiers that listen service providers
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            appInfo,
            sysService,
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeModeProvider(
            authService,
            accountsService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(
        builder: (context, themeModeProvider, child) {
      // register the  router deligate as listener of the app state.
      AppStateProvider appState =
          Provider.of<AppStateProvider>(context, listen: false);
      appState.routeStateListener = _routerDelegate;
      return MaterialApp.router(
        title: 'Amber pencil',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: primarySwatchLight,
          fontFamily: fontFamilySansSerif,
          textTheme: textTheme,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: primarySwatchDark,
          fontFamily: fontFamilySansSerif,
          textTheme: textTheme,
        ),
        themeMode: themeModeProvider.themeMode,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
    });
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(
      RouteInformation routeInformation) async {
    return AppRoute.fromPath(routeInformation.location);
  }

  @override
  RouteInformation restoreRouteInformation(AppRoute configuration) {
    return RouteInformation(location: configuration.path);
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoute>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<AppRoute>,
        RouteStateListener {
  ClientState _clientState = initialClientState;
  List<AppRoute> _routes = [AppRoute(name: rootRouteName)];

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  setClientState(ClientState clientState) {
    if (_clientState != clientState) {
      // go the top route of the given client state.
      _clientState = clientState;
      _routes = [
        AppRoute(
          name: autorizedRoutes[_clientState]?[0] ?? rootRouteName,
        ),
      ];
      notifyListeners();
    }
  }

  @override
  setRoute(AppRoute appRoute) {
    // guard
    if (!(autorizedRoutes[_clientState]?.contains(appRoute.name) ?? false)) {
      appRoute = AppRoute(
        name: autorizedRoutes[_clientState]?[0] ?? RouteName.loading,
      );
    }

    // avoid re-regist the same route.
    final int index = _routes.indexOf(appRoute);
    if (index < 0) {
      _routes = [..._routes, appRoute];
      notifyListeners();
    } else if ((index + 1) < _routes.length) {
      _routes = _routes.sublist(0, index + 1);
      notifyListeners();
    }
  }

  @override
  AppRoute get currentConfiguration => _routes.last;

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    setRoute(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _routes
          .map<MaterialPage>(
            (route) => MaterialPage(
              key: ValueKey('page-${route.name.toShortString()}'),
              child: BaseScreen(
                child: getScreen(route),
                route: route,
              ),
            ),
          )
          .toList(),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_routes.length > 1) {
          _routes.removeLast();
          notifyListeners();
        }
        return true;
      },
    );
  }

  @visibleForTesting
  Widget getScreen(AppRoute appRoute) {
    switch (appRoute.name) {
      case RouteName.home:
        return HomeScreen(route: appRoute);
      case RouteName.loading:
        return LoadingScreen(route: appRoute);
      case RouteName.signin:
        return SignInScreen(route: appRoute);
      case RouteName.verify:
        return EmailVerifyScreen(route: appRoute);
      case RouteName.prefs:
        return PreferencesScreen(route: appRoute);
      case RouteName.info:
        return AppInfoScreen(route: appRoute);
      default:
        return UnknownScreen(route: appRoute);
    }
  }

  @visibleForTesting
  ClientState get clientState => _clientState;

  @visibleForTesting
  List<AppRoute> get routes => _routes;
}
