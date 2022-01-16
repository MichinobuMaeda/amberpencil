import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/app_route.dart';
import '../models/app_state_provider.dart';
import '../utils/platform_web.dart';
import 'slivers/app_info_sliver.dart';
import 'slivers/edit_my_name_sliver.dart';
import 'slivers/edit_my_email_password_sliver.dart';
import 'slivers/email_verify_sliver.dart';
import 'slivers/groups_sliver.dart';
import 'slivers/loading_sliver.dart';
import 'slivers/page_title_sliver.dart';
import 'slivers/policy_sliver.dart';
import 'slivers/sign_in_sliver.dart';
import 'slivers/sign_out_sliver.dart';
import 'slivers/theme_mode_sliver.dart';
import 'slivers/home_sliver.dart';
import 'slivers/unknown_sliver.dart';
import 'widgets/vertical_label_icon_button.dart';

class BaseScreen extends StatelessWidget {
  final AppRoute route;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BaseScreen({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.of(context).size.width < 480;
    ButtonStyle menuButtonStype =
        Theme.of(context).brightness == Brightness.light
            ? TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary,
              )
            : TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onSurface,
              );

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          key: _scaffoldKey,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    pinned: appState.updateIsAvailable,
                    snap: false,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                    toolbarHeight: 72,
                    leading: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Image(image: logoAsset),
                    ),
                    actions: (autorizedRoutes[appState.clientState] ?? [])
                        .map(
                          (route) => menuItems.firstWhere(
                            (item) => item.route == route,
                          ),
                        )
                        .where(
                          (item) => item.route != route.name || !mobile,
                        )
                        .map(
                          (item) => VerticalLabelIconButton(
                            label: item.label,
                            icon: item.icon,
                            style: menuButtonStype,
                            fontSize: fontSizeBody * 0.75,
                            onPressed: item.route == route.name
                                ? null
                                : () {
                                    appState.goRoute(
                                      AppRoute(name: item.route),
                                    );
                                  },
                          ),
                        )
                        .toList(),
                    bottom: appState.updateIsAvailable
                        ? PreferredSize(
                            preferredSize: const Size.fromHeight(54.0),
                            child: MaterialBanner(
                              content: const Text(
                                'アプリを更新してください',
                                textAlign: TextAlign.right,
                              ),
                              actions: const [
                                IconButton(
                                  onPressed: reloadWebAapp,
                                  icon: Icon(Icons.system_update),
                                )
                              ],
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.amber.shade900
                                  : Colors.amber.shade400,
                            ),
                          )
                        : null,
                  ),
                ),
              ];
            },
            body: SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                builder: (BuildContext context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      ...menuItems
                          .where((item) => item.route == route.name)
                          .map((item) => PageTitileSliver(
                                title: item.label,
                                icon: item.icon,
                              )),
                      if (route.name == RouteName.loading)
                        const LoadingSliver(),
                      if (route.name == RouteName.signin) const SignInSliver(),
                      if (route.name == RouteName.verify)
                        const EmailVerifySliver(),
                      if (route.name == RouteName.home) const HomeSliver(),
                      if (route.name == RouteName.admin) const GroupsSliver(),
                      if (route.name == RouteName.signin ||
                          route.name == RouteName.verify ||
                          route.name == RouteName.prefs)
                        const ThemeModeSliver(),
                      if (route.name == RouteName.prefs)
                        const EditMyNameSliver(),
                      if (route.name == RouteName.prefs)
                        const EditMyEmaiPasswordSliver(),
                      if (route.name == RouteName.prefs) const SignOutSliver(),
                      if (route.name == RouteName.info) const AppInfoPSliver(),
                      if (route.name == RouteName.info) const PolicySliver(),
                      if (route.name == RouteName.unknown)
                        const UnknownSliver(),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
