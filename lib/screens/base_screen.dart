import 'package:amberpencil/config/routes.dart';
import 'package:amberpencil/models/app_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state_provider.dart';

class BaseScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String name;
  final Widget child;

  BaseScreen({
    Key? key,
    required this.child,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: AppBar(
          title: const Text('Amber pencil'),
          actions: [
            IconButton(
              onPressed: () {
                appState.goRoute(AppRoute(name: infoRouteName));
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
