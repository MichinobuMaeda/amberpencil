import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/user_bloc.dart';
import '../../blocs/conf_bloc.dart';
import '../../config/theme.dart';
import '../../config/app_info.dart';
import '../../router.dart';
import '../theme_widgets/update_app_button.dart';
import 'vertical_label_icon_button.dart';

class AppBarSliver extends StatelessWidget {
  final bool forceElevated;

  const AppBarSliver({
    Key? key,
    required this.forceElevated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        snap: false,
        floating: true,
        forceElevated: forceElevated,
        toolbarHeight: baseFontSize * 4,
        leading: const Padding(
          padding: EdgeInsets.all(spacing / 4),
          child: Image(image: logoAsset),
        ),
        actions: (authorizedRoutes(context.watch<UserBloc>().state))
            .where((route) =>
                !isMobile(context) || route != GoRouter.of(context).location)
            .map(
              (route) => VerticalLabelIconButton(
                label: getPage(context, route).label,
                icon: getPage(context, route).icon,
                style: TextButton.styleFrom(
                  primary: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                fontSize: baseFontSize * 0.75,
                onPressed: route == GoRouter.of(context).location
                    ? null
                    : () => GoRouter.of(context).go(route),
              ),
            )
            .toList(),
        bottom: (context.select<ConfBloc, String?>(
                      (bloc) => bloc.state?.version,
                    ) ??
                    version) !=
                version
            ? const PreferredSize(
                preferredSize: Size.fromHeight(baseFontSize * 3.4),
                child: UpdateAppButton(),
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(spacing / 8),
                child: SizedBox(height: spacing / 8),
              ),
      );
}
