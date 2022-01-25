import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/route_bloc.dart';
import '../config/routes.dart';
import 'slivers/app_info_sliver.dart';
import 'slivers/edit_my_name_sliver.dart';
import 'slivers/edit_my_email_password_sliver.dart';
import 'slivers/email_verify_sliver.dart';
import 'slivers/accounts_sliver.dart';
import 'slivers/groups_sliver.dart';
import 'slivers/loading_sliver.dart';
import 'slivers/page_title_sliver.dart';
import 'slivers/policy_sliver.dart';
import 'slivers/section_header_sliver.dart';
import 'slivers/sign_in_sliver.dart';
import 'slivers/sign_out_sliver.dart';
import 'slivers/theme_mode_sliver.dart';
import 'slivers/home_sliver.dart';
import 'slivers/unknown_sliver.dart';

import 'theme_widgets/app_bar.dart';

class BaseScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BaseScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: AppBarSliver(forceElevated: innerBoxIsScrolled),
            ),
          ],
          body: SafeArea(
            top: false,
            bottom: false,
            child: Builder(
              builder: (BuildContext context) => CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  ...contents(
                    context.watch<RouteBloc>().state.history.last,
                    AppLocalizations.of(context)!,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  List<Widget> contents(
    AppRoute route,
    AppLocalizations l10n,
  ) =>
      [
        const PageTitileSliver(),
        if (route.name == RouteName.loading) ...[
          const LoadingSliver(),
        ],
        if (route.name == RouteName.signin) ...[
          const SignInSliver(),
          const ThemeModeSliver(),
        ],
        if (route.name == RouteName.verify) ...[
          const EmailVerifySliver(),
          const ThemeModeSliver(),
        ],
        if (route.name == RouteName.home) ...[
          const HomeSliver(),
        ],
        if (route.name == RouteName.admin) ...[
          SectionHeaderSliver(l10n.groups),
          const GroupsSliver(),
          SectionHeaderSliver(l10n.accounts),
          const AccountsSliver(),
        ],
        if (route.name == RouteName.prefs) ...[
          const ThemeModeSliver(),
          const EditMyNameSliver(),
          const EditMyEmaiPasswordSliver(),
          const SignOutSliver(),
        ],
        if (route.name == RouteName.info) ...[
          const AppInfoPSliver(),
          const PolicySliver(),
        ],
        if (route.name == RouteName.unknown) ...[
          const UnknownSliver(),
        ],
      ];
}
