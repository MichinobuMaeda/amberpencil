import 'package:flutter/material.dart';
import 'l10n.dart';

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

List<MenuItem> menuItems(BuildContext context) => [
      MenuItem(
        routeName: RouteName.loading,
        icon: const Icon(Icons.autorenew),
        label: L10n.of(context)!.connecting,
      ),
      MenuItem(
        routeName: RouteName.signin,
        icon: const Icon(Icons.login),
        label: L10n.of(context)!.signIn,
      ),
      MenuItem(
        routeName: RouteName.verify,
        icon: const Icon(Icons.mark_email_read),
        label: L10n.of(context)!.verifyEmail,
      ),
      MenuItem(
        routeName: RouteName.home,
        icon: const Icon(Icons.home),
        label: L10n.of(context)!.home,
      ),
      MenuItem(
        routeName: RouteName.prefs,
        icon: const Icon(Icons.settings),
        label: L10n.of(context)!.settings,
      ),
      MenuItem(
        routeName: RouteName.admin,
        icon: const Icon(Icons.handyman),
        label: L10n.of(context)!.admin,
        admin: true,
      ),
      MenuItem(
        routeName: RouteName.info,
        icon: const Icon(Icons.info),
        label: L10n.of(context)!.aboutApp,
      ),
    ];

const bool keepHistory = false;
