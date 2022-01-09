import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../models/app_route.dart';
import '../../models/app_state_provider.dart';
import '../../utils/platform_web.dart';
import '../widgets.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'app_info_screen.dart';
import 'sign_in_screen.dart';
import 'email_verify_screen.dart';
import 'preferences_screen.dart';
import 'admin_screen.dart';
import 'unknown_screen.dart';

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

  @visibleForTesting
  Widget getScreen(RouteName name) {
    switch (name) {
      case RouteName.home:
        return const HomeScreen(key: ValueKey('HomeScreen'));
      case RouteName.loading:
        return const LoadingScreen(key: ValueKey('LoadingScreen'));
      case RouteName.signin:
        return const SignInScreen(key: ValueKey('SignInScreen'));
      case RouteName.verify:
        return const EmailVerifyScreen(key: ValueKey('EmailVerifyScreen'));
      case RouteName.prefs:
        return const PreferencesScreen(key: ValueKey('PreferencesScreen'));
      case RouteName.admin:
        return const AdminScreen(key: ValueKey('AdminScreen'));
      case RouteName.info:
        return const AppInfoScreen(key: ValueKey('AppInfoScreen'));
      default:
        return const UnknownScreen(key: ValueKey('UnknownScreen'));
    }
  }

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
                    pinned: appState.updateIsAvailable(),
                    snap: false,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
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
                    bottom: appState.updateIsAvailable()
                        ? PreferredSize(
                            preferredSize: const Size.fromHeight(28.0),
                            child: TextButton.icon(
                              icon: const Icon(Icons.system_update),
                              label: const Text('アプリを更新してください'),
                              style: menuButtonStype,
                              onPressed: () {
                                reloadWebAapp();
                              },
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
                          .where(
                            (item) => item.route == widget.route.name,
                          )
                          .map(
                            (item) => SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      width: fontSizeH2 * 1.6,
                                      height: fontSizeH2 * 1.6,
                                      child: item.icon,
                                    ),
                                    Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: fontSizeH2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      getScreen(widget.route.name),
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
