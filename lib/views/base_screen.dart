import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../models/app_route.dart';
import '../models/app_state_provider.dart';
import '../utils/platform_web.dart';
import 'panels/app_info_panel.dart';
import 'panels/edit_my_account_panel.dart';
import 'panels/email_verify_panel.dart';
import 'panels/groups_panel.dart';
import 'panels/loading_panel.dart';
import 'panels/page_title_panel.dart';
import 'panels/policy_panel.dart';
import 'panels/sign_in_panel.dart';
import 'panels/sign_out_panel.dart';
import 'panels/theme_mode_panel.dart';
import 'panels/home_panel.dart';
import 'panels/unknown_panel.dart';
import 'widgets.dart';

class BaseScreen extends StatefulWidget {
  final AppRoute route;

  const BaseScreen({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BaseState();
}

class _BaseState extends State<BaseScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                          (item) => item.route != widget.route.name || !mobile,
                        )
                        .map(
                          (item) => VerticalLabelIconButton(
                            label: item.label,
                            icon: item.icon,
                            style: menuButtonStype,
                            fontSize: fontSizeBody * 0.75,
                            onPressed: item.route == widget.route.name
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
                          .where((item) => item.route == widget.route.name)
                          .map((item) => PageTitilePanel(
                                title: item.label,
                                icon: item.icon,
                              )),
                      if (widget.route.name == RouteName.loading)
                        const LoadingPanel(),
                      if (widget.route.name == RouteName.signin)
                        const SignInPanel(),
                      if (widget.route.name == RouteName.verify)
                        const EmailVerifyPanel(),
                      if (widget.route.name == RouteName.home)
                        const HomePanel(),
                      if (widget.route.name == RouteName.admin)
                        const GroupsPanel(),
                      if (widget.route.name == RouteName.signin ||
                          widget.route.name == RouteName.verify ||
                          widget.route.name == RouteName.prefs)
                        const ThemeModePanel(),
                      if (widget.route.name == RouteName.prefs)
                        const EditMyAccountPanel(),
                      if (widget.route.name == RouteName.prefs)
                        const SignOutPanel(),
                      if (widget.route.name == RouteName.info)
                        const AppInfoPanel(),
                      if (widget.route.name == RouteName.info)
                        const PolicyPanel(),
                      if (widget.route.name == RouteName.unknown)
                        const UnknownPanel(),
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
