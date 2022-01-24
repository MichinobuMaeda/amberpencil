import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/route_bloc.dart';
import 'config/routes.dart';
import 'views/base_screen.dart';
import 'views/helpers/no_animation_route_transition_deligate.dart';

class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  final TransitionDelegate transitionDelegate = NoAnimationTransitionDelegate();
  final BuildContext _context;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate(BuildContext context)
      : _context = context,
        navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoute get currentConfiguration =>
      _context.read<RouteBloc>().getCurrentRoute();

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    _context.read<RouteBloc>().add(GoRoute(configuration));
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        transitionDelegate: transitionDelegate,
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
