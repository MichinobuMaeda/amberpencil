import 'package:flutter/material.dart';
import '../config/routes.dart';

class AppRoute {
  final String name;
  final String? id;

  AppRoute({required this.name, this.id});

  @override
  bool operator ==(Object other) =>
      other is AppRoute && other.name == name && other.id == id;

  @override
  int get hashCode => hashValues(name, id);

  @override
  String toString() => id == null
      ? 'AppRoute(name: "$name")'
      : 'AppRoute(name: "$name", id: "$id")';

  bool get top => topRouteNames.contains(name);

  String get path => id == null ? '/$name' : '/$name"/$id';

  factory AppRoute.fromPath(String? path) {
    final uri = Uri.parse(path ?? '/$loadingRouteName');
    return AppRoute(
      name: uri.pathSegments.isEmpty
          ? homeRouteName
          : (routeNames.contains(uri.pathSegments[0])
              ? uri.pathSegments[0]
              : unknownRouteName),
      id: uri.pathSegments.length > 2 ? uri.pathSegments[1] : null,
    );
  }
}
