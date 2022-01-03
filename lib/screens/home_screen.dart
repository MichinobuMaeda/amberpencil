import 'package:flutter/material.dart';
import '../models/app_route.dart';

class HomeScreen extends StatelessWidget {
  final AppRoute route;
  const HomeScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Home');
  }
}
