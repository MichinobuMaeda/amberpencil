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
        title: appState.appInfo.name,
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
  List<AppRoute> _routes = [AppRoute(name: initialRouteName)];
  List<AppRoute> _menuRoutes = autorizedRoutes[ClientState.loading]!
      .map((name) => AppRoute(name: name))
      .toList();

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
      _menuRoutes = autorizedRoutes[clientState]!
          .map((name) => AppRoute(name: name))
          .toList();
      notifyListeners();
    }
  }

  @override
  setRoute(AppRoute appRoute) {
    // guard
    if (!_menuRoutes.contains(appRoute)) {
      appRoute = _menuRoutes[0];
    }

    if (_routes[0] != appRoute) {
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
      transitionDelegate: NoAnimationTransitionDelegate(),
      pages: _routes
          .map<MaterialPage>(
            (route) => MaterialPage(
              key: ValueKey('page-${route.name.toShortString()}'),
              child: BaseScreen(
                menuRoutes: _menuRoutes,
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

  @visibleForTesting
  List<AppRoute> get menuRoutes => _menuRoutes;
}

// https://docs.flutter.dev/release/breaking-changes/route-transition-record-and-transition-delegate
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      // Renames isEntering to isWaitingForEnteringDecision.
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final RouteTransitionRecord exitingPageRoute
        in locationToExitingPageRoute.values) {
      // Checks the isWaitingForExitingDecision before calling the markFor methods.
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final List<RouteTransitionRecord>? pagelessRoutes =
            pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}
