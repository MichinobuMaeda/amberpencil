import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/route_bloc.dart';
import 'config/routes.dart';
import 'views/base_screen.dart';

class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  final BuildContext context;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate(this.context) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoute get currentConfiguration =>
      context.read<RouteBloc>().getCurrentRoute();

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    context.read<RouteBloc>().add(GoRouteEvent(configuration));
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: context
            .watch<RouteBloc>()
            .state
            .history
            .map<MaterialPage>(
              (route) => MaterialPage(
                key: ValueKey('page-${route.name.toShortString()}'),
                child: BaseScreen(key: ValueKey('${route.name}:${route.id}')),
              ),
            )
            .toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;

          context.read<RouteBloc>().add(PopRouteEvent());
          return true;
        },
      );
}

class AppRouteInformationParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(
          RouteInformation routeInformation) async =>
      AppRoute.fromPath(routeInformation.location);

  @override
  RouteInformation restoreRouteInformation(AppRoute configuration) =>
      RouteInformation(location: configuration.path);
}
