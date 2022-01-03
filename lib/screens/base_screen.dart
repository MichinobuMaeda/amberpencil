import 'package:flutter/material.dart';
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

class MenuItem {
  final String name;
  final Icon icon;
  final String label;
  final List<ClientState> states;

  const MenuItem({
    required this.name,
    required this.icon,
    required this.label,
    required this.states,
  });
}

const List<MenuItem> menuItems = [
  MenuItem(
    name: 'loading',
    icon: Icon(Icons.autorenew),
    label: 'ホーム',
    states: [ClientState.loading],
  ),
  MenuItem(
    name: 'signin',
    icon: Icon(Icons.login),
    label: 'ログイン',
    states: [ClientState.guest],
  ),
  MenuItem(
    name: 'verify',
    icon: Icon(Icons.mark_email_read),
    label: 'メールアドレスの確認',
    states: [ClientState.pending],
  ),
  MenuItem(
    name: '',
    icon: Icon(Icons.home),
    label: 'ホーム',
    states: [ClientState.authenticated],
  ),
  MenuItem(
    name: 'prefs',
    icon: Icon(Icons.settings),
    label: '設定',
    states: [
      ClientState.guest,
      ClientState.pending,
      ClientState.authenticated,
    ],
  ),
  MenuItem(
    name: 'info',
    icon: Icon(Icons.info),
    label: 'このアプリについて',
    states: [
      ClientState.loading,
      ClientState.guest,
      ClientState.pending,
      ClientState.authenticated
    ],
  ),
];

class BaseScreen extends StatefulWidget {
  final AppStateProvider appState;

  const BaseScreen({
    Key? key,
    required this.appState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BaseState();
}

class _BaseState extends State<BaseScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<MenuItem> _tabItems;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabItems = menuItems
        .where((item) => item.states.contains(widget.appState.clientState))
        .toList();
    _tabController = TabController(
      initialIndex: 0,
      vsync: this,
      length: _tabItems.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(widget.appState.appInfo.name),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              automaticallyImplyLeading: false,
              bottom: TabBar(
                tabs: _tabItems
                    .map((item) => Tab(child: Text(item.label)))
                    .toList(),
                controller: _tabController,
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            TabBarView(
              children: _tabItems.map((item) => getScreen(item.name)).toList(),
              controller: _tabController,
            ),
            Visibility(
              visible: widget.appState.updateIsAvailable(),
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
  Widget getScreen(String name) {
    switch (name) {
      case '':
        return const HomeScreen();
      case 'loading':
        return const LoadingScreen();
      case 'signin':
        return const SignInScreen();
      case 'verify':
        return const EmailVerifyScreen();
      case 'prefs':
        return const PreferencesScreen();
      case 'info':
        return const AppInfoScreen();
      default:
        return const UnknownScreen();
    }
  }
}
