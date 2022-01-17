import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../config/routes.dart';

class AppRoute extends Equatable {
  final RouteName name;
  final String? id;

  const AppRoute({required this.name, this.id});

  @override
  String toString() => id == null
      ? 'AppRoute(name: "${name.toShortString()}")'
      : 'AppRoute(name: "${name.toShortString()}", id: "$id")';

  String get path =>
      id == null ? '/${name.toShortString()}' : '/${name.toShortString()}"/$id';

  factory AppRoute.fromPath(String? path) {
    final uri = Uri.parse(path ?? '/');
    return AppRoute(
      name: uri.pathSegments.isEmpty
          ? rootRouteName
          : RouteName.values.firstWhere(
              (name) => name.toShortString() == uri.pathSegments[0],
              orElse: () => unknownRouteName,
            ),
      id: uri.pathSegments.length > 2 ? uri.pathSegments[1] : null,
    );
  }

  @override
  List<Object?> get props => [name, id];
}

class RouteState {
  final ClientState _clientState;
  final List<AppRoute> _history;

  RouteState({
    required ClientState clientState,
    required List<AppRoute> history,
  })  : _clientState = clientState,
        _history = history;

  ClientState get clientState => _clientState;
  List<AppRoute> get history => _history;

  RouteState copyWith({
    ClientState? clientState,
    List<AppRoute>? history,
  }) =>
      RouteState(
        clientState: clientState ?? _clientState,
        history: history ?? _history,
      );

  @override
  bool operator ==(Object other) =>
      other is RouteState &&
      other.clientState == clientState &&
      listEquals<AppRoute>(other.history, _history);

  @override
  int get hashCode => hashValues(
        clientState,
        hashList(_history),
      );
}

abstract class RouteEvent {}

class GoRouteEvent extends RouteEvent {
  final AppRoute route;

  GoRouteEvent(this.route);
}

class PopRouteEvent extends RouteEvent {}

class ClientStateChangedEvent extends RouteEvent {
  final ClientState clientState;

  ClientStateChangedEvent(this.clientState);
}

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc()
      : super(
          RouteState(
            clientState: ClientState.loading,
            history: const [AppRoute(name: RouteName.loading)],
          ),
        ) {
    on<ClientStateChangedEvent>(onClientStateChangedEvent);
    on<GoRouteEvent>(onGoRouteEvent);
    on<PopRouteEvent>(onPopRouteEvent);
  }

  void onClientStateChangedEvent(
    ClientStateChangedEvent event,
    Emitter<RouteState> emit,
  ) {
    // go the top route of the given client state.
    if (state.clientState != event.clientState) {
      final List<RouteName> authorized = getAuthorizedRoutes(event.clientState);
      emit(
        RouteState(
          clientState: event.clientState,
          history: [
            AppRoute(name: _getTopRouteName(authorized)),
          ],
        ),
      );
    }
  }

  void onGoRouteEvent(
    GoRouteEvent event,
    Emitter<RouteState> emit,
  ) {
    // guard
    final List<RouteName> authorized = getAuthorizedRoutes(state.clientState);
    final AppRoute next = (authorized.contains(event.route.name))
        ? event.route
        : AppRoute(name: _getTopRouteName(authorized));
    emit(
      keepHistory
          ? state.history.contains(next)
              ? state.history.last == next
                  ? state
                  : state.copyWith(
                      history: state.history.sublist(
                        0,
                        state.history.indexOf(next) - 1,
                      ),
                    )
              : state.copyWith(
                  history: [...state.history, next],
                )
          : state.copyWith(
              history: [next],
            ),
    );
  }

  void onPopRouteEvent(
    PopRouteEvent event,
    Emitter<RouteState> emit,
  ) {
    if (state.history.length > 1) {
      emit(
        state.copyWith(
          history: state.history.sublist(0, state.history.length - 1),
        ),
      );
    }
  }

  AppRoute getCurrentRoute() => state.history.last;

  static List<RouteName> getAuthorizedRoutes(ClientState clientState) =>
      autorizedRoutes[clientState] ?? [];

  RouteName _getTopRouteName(List<RouteName> authorized) =>
      authorized.isNotEmpty ? authorized.first : RouteName.loading;
}
