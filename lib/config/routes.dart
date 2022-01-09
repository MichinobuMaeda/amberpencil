import 'package:flutter/material.dart';

enum ClientState { loading, guest, pending, authenticated }

const ClientState initialClientState = ClientState.loading;

enum RouteName { unknown, home, loading, signin, verify, info, prefs, admin }

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
    RouteName.info,
  ],
  ClientState.pending: [
    RouteName.verify,
    RouteName.info,
  ],
  ClientState.authenticated: [
    RouteName.home,
    RouteName.prefs,
    RouteName.admin,
    RouteName.info,
  ],
};

class MenuItem {
  final Icon icon;
  final String label;
  final RouteName route;
  final bool admin;
  const MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.admin = false,
  });
}

const List<MenuItem> menuItems = [
  MenuItem(
    icon: Icon(Icons.autorenew),
    label: '接続中',
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
    icon: Icon(Icons.handyman),
    label: '管理',
    route: RouteName.admin,
    admin: true,
  ),
  MenuItem(
    icon: Icon(Icons.info),
    label: 'アプリについて',
    route: RouteName.info,
  ),
];

const bool keepHistory = false;
