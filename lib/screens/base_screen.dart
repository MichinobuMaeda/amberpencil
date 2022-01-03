import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amberpencil/config/routes.dart';
import 'package:amberpencil/models/app_route.dart';
import '../config/theme.dart';
import '../models/app_state_provider.dart';
import '../utils/web.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'app_info_screen.dart';
import 'sign_in_screen.dart';
import 'email_verify_screen.dart';
import 'preferences_screen.dart';
import 'unknown_screen.dart';

class BaseScreen extends StatefulWidget {
  final List<AppRoute> menuRoutes;
  final AppRoute route;

  const BaseScreen({
    Key? key,
    required this.menuRoutes,
    required this.route,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BaseState();
}

class _BaseState extends State<BaseScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.menuRoutes.indexOf(widget.route),
      vsync: this,
      length: widget.menuRoutes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(appState.appInfo.name),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              automaticallyImplyLeading: false,
              actions: [
                PopupMenuButton<RouteName>(
                  onSelected: (RouteName selected) {
                    appState.goRoute(AppRoute(name: selected));
                  },
                  itemBuilder: (BuildContext context) => menuItems
                      .where((item) =>
                          autorizedRoutes[appState.clientState]
                              ?.contains(item.route) ??
                          false)
                      .map((item) => PopupMenuItem<RouteName>(
                            value: item.route,
                            child: ListTile(
                              leading: item.icon,
                              title: Text(item.label),
                            ),
                            enabled: item.route != widget.route.name,
                          ))
                      .toList(),
                ),
              ],
              bottom: TabBar(
                tabs: widget.menuRoutes
                    .map(
                      (route) => menuItems
                          .firstWhere((item) => item.route == route.name),
                    )
                    .map((item) => Tab(
                          child: Text(item.label),
                        ))
                    .toList(),
                controller: _tabController,
                onTap: (index) {
                  appState.goRoute(widget.menuRoutes[index]);
                },
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            TabBarView(
              children:
                  widget.menuRoutes.map((route) => getScreen(route)).toList(),
              controller: _tabController,
            ),
            Visibility(
              visible: appState.updateIsAvailable(),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: fontSizeBody / 4,
                    horizontal: fontSizeBody / 4,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.system_update),
                    label: const Text('アプリを更新してください'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(colorDanger),
                    ),
                    onPressed: () {
                      reloadWebAapp();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @visibleForTesting
  Widget getScreen(AppRoute appRoute) {
    switch (appRoute.name) {
      case RouteName.home:
        return HomeScreen(route: appRoute);
      case RouteName.loading:
        return LoadingScreen(route: appRoute);
      case RouteName.signin:
        return SignInScreen(route: appRoute);
      case RouteName.verify:
        return EmailVerifyScreen(route: appRoute);
      case RouteName.prefs:
        return PreferencesScreen(route: appRoute);
      case RouteName.info:
        return AppInfoScreen(route: appRoute);
      default:
        return UnknownScreen(route: appRoute);
    }
  }
}
