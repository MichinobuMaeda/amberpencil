import 'package:flutter/material.dart';
import '../config/routes.dart';

class AppRoute {
  final RouteName name;
  final String? id;

  AppRoute({required this.name, this.id});

  @override
  bool operator ==(Object other) =>
      other is AppRoute && other.name == name && other.id == id;

  @override
  int get hashCode => hashValues(name, id);

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
}
