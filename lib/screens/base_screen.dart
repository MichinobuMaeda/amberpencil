import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amberpencil/config/routes.dart';
import 'package:amberpencil/models/app_route.dart';
import '../config/theme.dart';
import '../models/app_state_provider.dart';
import '../utils/web.dart';

class BaseScreen extends StatefulWidget {
  final AppRoute route;
  final Widget child;
  final List<Widget>? tabs;

  const BaseScreen({
    Key? key,
    required this.child,
    required this.route,
    this.tabs,
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
    _tabController = TabController(vsync: this, length: 3);
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
              title: const Text('Amber pencil'),
              pinned: widget.tabs != null,
              floating: widget.tabs != null,
              forceElevated: innerBoxIsScrolled,
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
              bottom: widget.tabs == null
                  ? null
                  : TabBar(
                      tabs: widget.tabs!,
                      controller: _tabController,
                    ),
            ),
          ];
        },
        body: Stack(
          children: [
            widget.child,
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
}
