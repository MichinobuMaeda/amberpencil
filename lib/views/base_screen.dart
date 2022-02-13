import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/repository_request_delegate_bloc.dart';

import 'theme_widgets/app_bar.dart';

class BaseScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> contents;

  BaseScreen({
    Key? key,
    required this.contents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: BlocProvider(
          create: (_) => RepositoryRequestBloc(context),
          lazy: false,
          child: Builder(
            builder: (context) => NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                      ...contents,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
