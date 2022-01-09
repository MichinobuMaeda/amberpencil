import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/app_info.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'models/theme_mode_provider.dart';
import 'models/app_state_provider.dart';
import 'models/app_info_provider.dart';
import 'models/app_route.dart';
import 'services/conf_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'views/screens/base_screen.dart';
import 'utils/env.dart';
import 'utils/platform_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  final String deepLink = getCurrentUrl();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await useFirebaseEmulators(
    appStaticInfo.version,
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
    firebase_storage.FirebaseStorage.instance,
  );

  // Service providers
  ConfService confService = ConfService(
    FirebaseFirestore.instance,
  );
  AuthService authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    deepLink,
  );
  AccountsService accountsService = AccountsService(
    FirebaseFirestore.instance,
  );

  runApp(
    MultiProvider(
      // Change notifiers that listen service providers
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeModeProvider(
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            appStaticInfo,
            confService,
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppInfoProvider(
            appStaticInfo,
            confService,
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
    return Consumer<ThemeModeProvider>(builder: (context, themeMode, child) {
      return Consumer<AppStateProvider>(builder: (context, appState, child) {
        AppInfoProvider appInfoProvider =
            Provider.of<AppInfoProvider>(context, listen: false);
        appState.routeStateListener = _routerDelegate;

        return MaterialApp.router(
          title: appInfoProvider.data.name,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          locale: const Locale('ja', 'JP'),
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeInformationParser,
        );
      });
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

    if (keepHistory) {
      // avoid re-regist the same route.
      final int index = _routes.indexOf(appRoute);
      if (index < 0) {
        _routes = [..._routes, appRoute];
        notifyListeners();
      } else if ((index + 1) < _routes.length) {
        _routes = _routes.sublist(0, index + 1);
        notifyListeners();
      }
    } else {
      _routes = [appRoute];
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
                key: ValueKey('${route.name}:${route.id}'),
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
  ClientState get clientState => _clientState;

  @visibleForTesting
  List<AppRoute> get routes => _routes;
}
