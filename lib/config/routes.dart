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
  final RouteName routeName;
  final Icon icon;
  final String label;
  final bool admin;
  const MenuItem({
    required this.routeName,
    required this.icon,
    required this.label,
    this.admin = false,
  });
}

const List<MenuItem> menuItems = [
  MenuItem(
    routeName: RouteName.loading,
    icon: Icon(Icons.autorenew),
    label: '接続中',
  ),
  MenuItem(
    routeName: RouteName.signin,
    icon: Icon(Icons.login),
    label: 'ログイン',
  ),
  MenuItem(
    routeName: RouteName.verify,
    icon: Icon(Icons.mark_email_read),
    label: 'メールアドレスの確認',
  ),
  MenuItem(
    routeName: RouteName.home,
    icon: Icon(Icons.home),
    label: 'ホーム',
  ),
  MenuItem(
    routeName: RouteName.prefs,
    icon: Icon(Icons.settings),
    label: '設定',
  ),
  MenuItem(
    routeName: RouteName.admin,
    icon: Icon(Icons.handyman),
    label: '管理',
    admin: true,
  ),
  MenuItem(
    routeName: RouteName.info,
    icon: Icon(Icons.info),
    label: 'アプリについて',
  ),
];

const bool keepHistory = false;
