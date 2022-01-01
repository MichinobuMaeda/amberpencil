import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'models/app_route.dart';
import 'config/version.dart';
import 'models/app_state_provider.dart';
import 'services/sys_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'screens/base_screen.dart';
import 'utils/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await useFirebaseEmulators(
    version,
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
    firebase_storage.FirebaseStorage.instance,
  );

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
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            sysService,
            authService,
            accountsService,
          ),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      _routerDelegate.setState(appState);
      return MaterialApp.router(
        title: 'Amber pencil',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: appState.themeMode,
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
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  AppStateProvider? _appState;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    initializeRouteNameMap();
  }

  void setState(AppStateProvider appStateModel) {
    _appState ??= appStateModel;
    if (_appState!.guard(_appState!.routes.last)) {
      notifyListeners();
    }
  }

  @override
  AppRoute get currentConfiguration =>
      _appState?.routes.last ?? AppRoute(name: loadingRouteName);

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    _appState!.goRoute(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _appState!.routes
          .map<MaterialPage>(
            (route) => MaterialPage(
              key: ValueKey('page-${route.name}'),
              child: BaseScreen(
                child: routeNameMap[route.name]!,
                name: route.name,
              ),
            ),
          )
          .toList(),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_appState!.routes.length > 1) {
          _appState!.routes.removeLast();
          notifyListeners();
        }
        return true;
      },
    );
  }
}
