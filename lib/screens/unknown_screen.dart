import 'package:flutter/material.dart';
import '../models/app_route.dart';

class UnknownScreen extends StatelessWidget {
  final AppRoute route;
  const UnknownScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Unknown');
  }
}
