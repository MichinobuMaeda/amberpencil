import 'package:flutter/material.dart';

enum ClientState { loading, guest, pending, authenticated }

const ClientState initialClientState = ClientState.loading;

enum RouteName { unknown, home, loading, signin, verify, info, prefs }

const RouteName initialRouteName = RouteName.loading;
const RouteName rootRouteName = RouteName.home;
const RouteName unknownRouteName = RouteName.unknown;

extension ParseToString on RouteName {
  String toShortString() {
    return this == rootRouteName ? '' : toString().split('.').last;
  }
}

// the top routes of each client state should require only name,
// not require id.
const Map<ClientState, List<RouteName>> autorizedRoutes = {
  ClientState.loading: [
    RouteName.loading,
    RouteName.info,
  ],
  ClientState.guest: [
    RouteName.signin,
    RouteName.prefs,
    RouteName.info,
  ],
  ClientState.pending: [
    RouteName.verify,
    RouteName.prefs,
    RouteName.info,
  ],
  ClientState.authenticated: [
    RouteName.home,
    RouteName.prefs,
    RouteName.info,
  ],
};

class MenuItem {
  final Icon icon;
  final String label;
  final RouteName route;
  const MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<MenuItem> menuItems = [
  MenuItem(
    icon: Icon(Icons.autorenew),
    label: 'ホーム',
    route: RouteName.loading,
  ),
  MenuItem(
    icon: Icon(Icons.login),
    label: 'ログイン',
    route: RouteName.signin,
  ),
  MenuItem(
    icon: Icon(Icons.mark_email_read),
    label: 'メールアドレスの確認',
    route: RouteName.verify,
  ),
  MenuItem(
    icon: Icon(Icons.home),
    label: 'ホーム',
    route: RouteName.home,
  ),
  MenuItem(
    icon: Icon(Icons.settings),
    label: '設定',
    route: RouteName.prefs,
  ),
  MenuItem(
    icon: Icon(Icons.info),
    label: 'このアプリについて',
    route: RouteName.info,
  ),
];
