import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CenteringColumn(
      children: [
        Text('Home'),
      ],
    );
  }
}
