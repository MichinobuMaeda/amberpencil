import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/l10n.dart';
import '../config/theme.dart';
import '../models/route_names.dart';

class BreadCrumbsSliver extends ConsumerWidget {
  final GoRouterState routerState;

  const BreadCrumbsSliver({
    super.key,
    required this.routerState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);

    return SliverToBoxAdapter(
      child: Container(
        color: listItemColor(context, -1),
        height: 40.0,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              TextButton.icon(
                onPressed: routerState.name == RouteNames.home.name
                    ? null
                    : () => router.goNamed(RouteNames.home.name),
                icon: const Icon(Icons.home),
                label: Text(L10n.of(context)!.home),
              ),
              if (routerState.name != RouteNames.home.name) const Text('»'),
              if (routerState.name == RouteNames.me.name)
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.account_circle),
                  label: Text(L10n.of(context)!.settings),
                ),
              if (routerState.name == RouteNames.about.name)
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.info),
                  label: Text(L10n.of(context)!.aboutApp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
