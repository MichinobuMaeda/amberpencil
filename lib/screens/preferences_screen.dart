import 'package:flutter/material.dart';
import '../models/app_route.dart';

class PreferencesScreen extends StatelessWidget {
  final AppRoute route;
  const PreferencesScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Preferences');
  }
}
