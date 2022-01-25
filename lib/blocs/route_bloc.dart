import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../config/routes.dart';
import '../models/conf.dart';
import 'my_account_bloc.dart';

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

class RouteState extends Equatable {
  final ClientState _clientState;
  final List<AppRoute> _history;

  const RouteState({
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
  List<Object?> get props => [_clientState, _history];
}

abstract class RouteEvent {}

class GoRoute extends RouteEvent {
  final AppRoute route;

  GoRoute(this.route);
}

class PopRouteEvent extends RouteEvent {}

class OnConfUpdated extends RouteEvent {
  final Conf? conf;

  OnConfUpdated(this.conf);
}

class OnAuthStateChecked extends RouteEvent {
  OnAuthStateChecked();
}

class OnMyAccountUpdated extends RouteEvent {
  final MyAccountStatus state;
  OnMyAccountUpdated(this.state);
}

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  bool _confReceived = false;
  bool _authStateChecked = false;
  bool _signIned = false;
  bool _emailVerified = false;

  RouteBloc()
      : super(
          const RouteState(
            clientState: ClientState.loading,
            history: [AppRoute(name: RouteName.loading)],
          ),
        ) {
    on<OnConfUpdated>(
      (
        OnConfUpdated event,
        Emitter<RouteState> emit,
      ) {
        _confReceived = event.conf != null;
        updateClientState(emit);
      },
    );

    on<OnAuthStateChecked>(
      (
        OnAuthStateChecked event,
        Emitter<RouteState> emit,
      ) {
        _authStateChecked = true;
        updateClientState(emit);
      },
    );

    on<OnMyAccountUpdated>(
      (
        OnMyAccountUpdated event,
        Emitter<RouteState> emit,
      ) {
        _signIned = event.state.me != null;
        _emailVerified = event.state.authUser?.emailVerified == true;
        updateClientState(emit);
      },
    );

    on<GoRoute>(
      (
        GoRoute event,
        Emitter<RouteState> emit,
      ) {
        // guard
        final List<RouteName> authorized =
            getAuthorizedRoutes(state.clientState);
        final AppRoute next = (authorized.contains(event.route.name))
            ? event.route
            : AppRoute(name: getTopRouteName(authorized));
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
      },
    );

    on<PopRouteEvent>((
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
    });
  }

  AppRoute getCurrentRoute() => state.history.last;

  static List<RouteName> getAuthorizedRoutes(ClientState clientState) =>
      autorizedRoutes[clientState] ?? [];

  static RouteName getTopRouteName(List<RouteName> authorized) =>
      authorized.isNotEmpty ? authorized.first : RouteName.loading;

  void updateClientState(Emitter emit) {
    final ClientState clientState = _confReceived && _authStateChecked
        ? _signIned
            ? _emailVerified
                ? ClientState.authenticated
                : ClientState.pending
            : ClientState.guest
        : ClientState.loading;

    if (state.clientState != clientState) {
      // go to the top route of the given client state.
      final List<RouteName> authorized = getAuthorizedRoutes(clientState);
      emit(
        RouteState(
          clientState: clientState,
          history: [
            AppRoute(name: getTopRouteName(authorized)),
          ],
        ),
      );
    }
  }
}
