import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'models/app_state_provider.dart';
import 'models/app_route.dart';
import 'views/base_screen.dart';

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
  List<AppRoute> _routes = [const AppRoute(name: rootRouteName)];

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
