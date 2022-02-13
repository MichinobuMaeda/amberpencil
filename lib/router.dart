import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'blocs/user_bloc.dart';
import 'config/l10n.dart';
import 'views/slivers/app_info_sliver.dart';
import 'views/slivers/edit_my_name_sliver.dart';
import 'views/slivers/edit_my_email_password_sliver.dart';
import 'views/slivers/email_verify_sliver.dart';
import 'views/slivers/accounts_sliver.dart';
import 'views/slivers/groups_sliver.dart';
import 'views/slivers/loading_sliver.dart';
import 'views/slivers/page_title_sliver.dart';
import 'views/slivers/policy_sliver.dart';
import 'views/slivers/section_header_sliver.dart';
import 'views/slivers/sign_in_sliver.dart';
import 'views/slivers/sign_out_sliver.dart';
import 'views/slivers/theme_mode_sliver.dart';
import 'views/slivers/home_sliver.dart';
import 'views/slivers/unknown_sliver.dart';
import 'views/base_screen.dart';

const String routeLoading = '/loading';
const String routeSignin = '/signin';
const String routeVerify = '/verify';
const String routeHome = '/';
const String routeAdmin = '/admin';
const String routePrefs = '/prefs';
const String routeInfo = '/info';

List<String> authorizedRoutes(UserState userState) {
  if (userState.confReceived && userState.authStateChecked) {
    if (userState.authUser == null || userState.me == null) {
      return [
        routeSignin,
        routeInfo,
      ];
    } else if (!userState.authUser!.emailVerified) {
      return [
        routeVerify,
        routeInfo,
      ];
    } else {
      return [
        routeHome,
        routePrefs,
        if (userState.me!.admin) routeAdmin,
        routeInfo,
      ];
    }
  } else {
    return [
      routeLoading,
      routeInfo,
    ];
  }
}

class PageItem {
  final Icon icon;
  final String label;

  const PageItem({
    required this.icon,
    required this.label,
  });
}

PageItem getPage(BuildContext context, String route) {
  const PageItem errorPage = PageItem(
    icon: Icon(Icons.error),
    label: 'Error',
  );

  try {
    switch (route) {
      case routeLoading:
        return PageItem(
          icon: const Icon(Icons.autorenew),
          label: L10n.of(context)!.connecting,
        );
      case routeSignin:
        return PageItem(
          icon: const Icon(Icons.login),
          label: L10n.of(context)!.signIn,
        );
      case routeVerify:
        return PageItem(
          icon: const Icon(Icons.mark_email_read),
          label: L10n.of(context)!.verifyEmail,
        );
      case routeHome:
        return PageItem(
          icon: const Icon(Icons.home),
          label: L10n.of(context)!.home,
        );
      case routeAdmin:
        return PageItem(
          icon: const Icon(Icons.handyman),
          label: L10n.of(context)!.admin,
        );
      case routePrefs:
        return PageItem(
          icon: const Icon(Icons.settings),
          label: L10n.of(context)!.settings,
        );
      case routeInfo:
        return PageItem(
          icon: const Icon(Icons.info),
          label: L10n.of(context)!.aboutApp,
        );
      default:
        return errorPage;
    }
  } catch (e) {
    return errorPage;
  }
}

final List<GoRoute> routes = [
  GoRoute(
    path: routeLoading,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          LoadingSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routeSignin,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          SignInSliver(),
          ThemeModeSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routeVerify,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          EmailVerifySliver(),
          ThemeModeSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routeHome,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          HomeSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routeAdmin,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: [
          const PageTitileSliver(),
          SectionHeaderSliver(L10n.of(context)!.groups),
          const GroupsSliver(),
          SectionHeaderSliver(L10n.of(context)!.account),
          const AccountsSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routePrefs,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          ThemeModeSliver(),
          EditMyNameSliver(),
          EditMyEmaiPasswordSliver(),
          SignOutSliver(),
        ],
      ),
    ),
  ),
  GoRoute(
    path: routeInfo,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      child: BaseScreen(
        contents: const [
          PageTitileSliver(),
          AppInfoPSliver(),
          PolicySliver(),
        ],
      ),
    ),
  ),
];

Widget routeErrorBuilder(BuildContext context, GoRouterState state) =>
    BaseScreen(
      contents: const [
        PageTitileSliver(),
        UnknownSliver(),
      ],
    );

String? Function(GoRouterState) guard(UserBloc userBloc) =>
    (GoRouterState state) {
      final List<String> activeRoutes = authorizedRoutes(userBloc.state);
      if (!activeRoutes.contains(state.subloc)) {
        return activeRoutes[0];
      }
      return null;
    };
