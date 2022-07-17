import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'providers/ui.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuStateProvider.notifier);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            snap: true,
            floating: true,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'SliverAppBar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              background: Image(
                image:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                        ? const AssetImage('images/logo_small.png')
                        : const AssetImage('images/logo_dark_small.png'),
                alignment: MediaQuery.of(context).size.width < 480.0
                    ? Alignment.topLeft
                    : Alignment.topCenter,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Go back',
                onPressed: () => menuState.state = Menu.back,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add',
                onPressed: () => menuState.state = Menu.add,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => menuState.state = Menu.edit,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () => menuState.state = Menu.search,
              ),
              PopupMenuButton<Menu>(
                icon: const Icon(Icons.more_horiz),
                position: PopupMenuPosition.under,
                initialValue: Menu.none,
                onSelected: (Menu item) => menuState.state = item,
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<Menu>(
                    value: Menu.profile,
                    child: ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text('Profile'),
                    ),
                  ),
                  const PopupMenuItem<Menu>(
                    value: Menu.preferences,
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Preferences'),
                    ),
                  ),
                  const PopupMenuItem<Menu>(
                    value: Menu.about,
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About this app'),
                    ),
                  ),
                  const PopupMenuItem<Menu>(
                    value: Menu.development,
                    child: ListTile(
                      leading: Icon(Icons.memory),
                      title: Text('Development'),
                    ),
                  ),
                ],
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text(ref.watch(menuStateProvider).name),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: listItemColor(context, index),
                  height: 100.0,
                  child: Center(
                    child: index == 0
                        ? ElevatedButton(
                            onPressed: () {},
                            style: filledButtonStyle(context),
                            child: const Text('Filled'),
                          )
                        : index == 1
                            ? ElevatedButton(
                                onPressed: () {},
                                child: const Text('Elevated'),
                              )
                            : index == 2
                                ? OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Outlined'),
                                  )
                                : Text('$index', textScaleFactor: 5),
                  ),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}
