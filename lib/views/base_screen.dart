import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/app_state_provider.dart';
import '../utils/platform_web.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'app_info_screen.dart';
import 'sign_in_screen.dart';
import 'email_verify_screen.dart';
import 'preferences_screen.dart';
import 'unknown_screen.dart';

class MenuItem {
  final String name;
  final Widget icon;
  final String label;
  final List<ClientState> states;

  const MenuItem({
    required this.name,
    required this.icon,
    required this.label,
    required this.states,
  });
}

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

  late final List<MenuItem> _menuItems;
  late final List<MenuItem> _tabItems;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    const Widget homeIcon = Image(
      image: AssetImage('assets/images/logo.png'),
      height: 24,
      width: 24,
    );

    _menuItems = [
      const MenuItem(
        name: 'loading',
        icon: Icon(Icons.autorenew),
        label: '準備中',
        states: [ClientState.loading],
      ),
      const MenuItem(
        name: 'signin',
        icon: Icon(Icons.login),
        label: 'ログイン',
        states: [ClientState.guest],
      ),
      const MenuItem(
        name: 'verify',
        icon: Icon(Icons.mark_email_read),
        label: 'メールの確認',
        states: [ClientState.pending],
      ),
      const MenuItem(
        name: '',
        icon: Icon(Icons.home),
        label: 'ホーム',
        states: [ClientState.authenticated],
      ),
      const MenuItem(
        name: 'prefs',
        icon: Icon(Icons.settings),
        label: '設定',
        states: [
          ClientState.guest,
          ClientState.pending,
          ClientState.authenticated,
        ],
      ),
      const MenuItem(
        name: 'info',
        icon: homeIcon,
        label: 'このアプリについて',
        states: [
          ClientState.loading,
          ClientState.guest,
          ClientState.pending,
          ClientState.authenticated
        ],
      ),
    ];
    _tabItems = _menuItems
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
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    if (widget.appState.clientState == ClientState.authenticated) {
      if (loadReauthMode()) {
        _tabController.index = 1;
        appState.updateSignedInAt();
      }
    }

    return SafeArea(
      left: false,
      right: false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          child: AppBar(
            flexibleSpace: Column(
              children: [
                TabBar(
                  key: ValueKey('TabBar:${widget.appState.clientState}'),
                  tabs: _tabItems
                      .map(
                        (item) => Tab(
                          child: Row(
                            children: [
                              item.icon,
                              const SizedBox(width: 4),
                              Text(item.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  controller: _tabController,
                  isScrollable: true,
                ),
              ],
            ),
          ),
          preferredSize: const Size.fromHeight(48.0),
        ),
        body: Stack(
          children: [
            TabBarView(
              key: ValueKey('TabBarView:${widget.appState.clientState}'),
              children: _tabItems
                  .map(
                    (item) => LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints viewportConstraints) {
                        return SingleChildScrollView(
                          controller: ScrollController(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: getScreen(item.name),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
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
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.system_update),
                    label: const Text('アプリを更新してください'),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onPressed: () {
                      reloadWebAapp();
                    },
                  ),
                ),
              ),
            ),
          ],
          // ),
        ),
      ),
    );
  }

  @visibleForTesting
  Widget getScreen(String name) {
    switch (name) {
      case '':
        return const HomeScreen(key: ValueKey('HomeScreen'));
      case 'loading':
        return const LoadingScreen(key: ValueKey('LoadingScreen'));
      case 'signin':
        return const SignInScreen(key: ValueKey('SignInScreen'));
      case 'verify':
        return const EmailVerifyScreen(key: ValueKey('EmailVerifyScreen'));
      case 'prefs':
        return const PreferencesScreen(key: ValueKey('PreferencesScreen'));
      case 'info':
        return const AppInfoScreen(key: ValueKey('AppInfoScreen'));
      default:
        return const UnknownScreen(key: ValueKey('UnknownScreen'));
    }
  }
}
