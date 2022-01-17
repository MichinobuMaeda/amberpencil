import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/route_bloc.dart';
import '../config/routes.dart';
import 'slivers/app_info_sliver.dart';
import 'slivers/edit_my_name_sliver.dart';
import 'slivers/edit_my_email_password_sliver.dart';
import 'slivers/email_verify_sliver.dart';
import 'slivers/groups_sliver.dart';
import 'slivers/loading_sliver.dart';
import 'slivers/page_title_sliver.dart';
import 'slivers/policy_sliver.dart';
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
                  ...contents(context.watch<RouteBloc>().state.history.last),
                ],
              ),
            ),
          ),
        ),
      );

  List<Widget> contents(AppRoute route) => [
        ...menuItems
            .where((item) => item.routeName == route.name)
            .map(
              (item) => PageTitileSliver(
                title: item.label,
                icon: item.icon,
              ),
            )
            .toList(),
        if (route.name == RouteName.loading) const LoadingSliver(),
        if (route.name == RouteName.signin) const SignInSliver(),
        if (route.name == RouteName.verify) const EmailVerifySliver(),
        if (route.name == RouteName.home) const HomeSliver(),
        if (route.name == RouteName.admin) const GroupsSliver(),
        if (route.name == RouteName.signin ||
            route.name == RouteName.verify ||
            route.name == RouteName.prefs)
          const ThemeModeSliver(),
        if (route.name == RouteName.prefs) const EditMyNameSliver(),
        if (route.name == RouteName.prefs) const EditMyEmaiPasswordSliver(),
        if (route.name == RouteName.prefs) const SignOutSliver(),
        if (route.name == RouteName.info) const AppInfoPSliver(),
        if (route.name == RouteName.info) const PolicySliver(),
        if (route.name == RouteName.unknown) const UnknownSliver(),
      ];
}
