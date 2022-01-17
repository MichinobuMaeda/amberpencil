import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/route_bloc.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/app_state_provider.dart';
import 'vertical_label_icon_button.dart';
import 'update_app_button.dart';

class AppBarSliver extends StatelessWidget {
  final bool forceElevated;
  const AppBarSliver({
    Key? key,
    required this.forceElevated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: context.watch<AppStateProvider>().updateIsAvailable,
        snap: false,
        floating: true,
        forceElevated: forceElevated,
        toolbarHeight: 72,
        leading: const Padding(
          padding: EdgeInsets.all(spacing / 4),
          child: Image(image: logoAsset),
        ),
        actions: activeMenuItems(context)
            .map(
              (item) => VerticalLabelIconButton(
                label: item.label,
                icon: item.icon,
                style: menuButtonStype(context),
                fontSize: baseFontSize * 0.75,
                onPressed: item.routeName ==
                        context.watch<RouteBloc>().state.history.last.name
                    ? null
                    : () {
                        context.read<RouteBloc>().add(
                              GoRouteEvent(AppRoute(name: item.routeName)),
                            );
                      },
              ),
            )
            .toList(),
        bottom: context.watch<AppStateProvider>().updateIsAvailable
            ? const PreferredSize(
                preferredSize: Size.fromHeight(54.0),
                child: UpdateAppButton(),
              )
            : null,
      );

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < fieldWidth;

  ButtonStyle menuButtonStype(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.onPrimary,
            )
          : TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.onSurface,
            );

  List<MenuItem> activeMenuItems(BuildContext context) =>
      RouteBloc.getAuthorizedRoutes(
        context.watch<RouteBloc>().state.clientState,
      )
          .map<MenuItem>(
            (route) => menuItems.singleWhere((item) => item.routeName == route),
          )
          .where((item) =>
              item.routeName !=
                  context.watch<RouteBloc>().state.history.last.name ||
              !isMobile(context))
          .toList();
}
