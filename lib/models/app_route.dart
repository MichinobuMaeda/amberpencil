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
