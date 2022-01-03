import 'package:flutter/material.dart';
import '../screens/scroll_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScrollScreen(
      child: Text('Home'),
    );
  }
}
