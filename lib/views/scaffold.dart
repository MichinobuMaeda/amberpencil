import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/l10n.dart';
import '../config/theme.dart';
import '../services/providers.dart';
import '../services/web.dart';
import 'bread_crumbs_sliver.dart';
import 'more_menu.dart';

enum Menu { none, preferences, about, development }

class MyScaffold extends ConsumerWidget {
  final GoRouterState routerState;
  final List<Widget> children;

  const MyScaffold({
    super.key,
    required this.routerState,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('${DateTime.now().toIso8601String()} Scaffold');
    bool updateAvailable = ref.watch(updateAvailableProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            snap: true,
            floating: true,
            expandedHeight: 152.0 + (updateAvailable ? 48.0 : 0),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(
                bottom: updateAvailable ? 48.0 : 8.0,
              ),
              title: Text(
                ref.watch(appTitileProvider),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              background: menuBackground(context),
            ),
            bottom: updateAvailable
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(0.0),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.system_update_alt),
                        label: Text(L10n.of(context)!.updateApp),
                        style: OutlinedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => uploadApp(),
                      ),
                    ),
                  )
                : null,
            actions: [
              const SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: L10n.of(context)!.add,
                onPressed: null,
              ),
              const SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: L10n.of(context)!.edit,
                onPressed: null,
              ),
              const SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: L10n.of(context)!.search,
                onPressed: null,
              ),
              const SizedBox(width: 16.0),
              MoreMenu(routerState: routerState),
            ],
            // backgroundColor: Theme.of(context).colorScheme.background,
          ),
          BreadCrumbsSliver(routerState: routerState),
          ...children,
        ],
      ),
    );
  }
}
