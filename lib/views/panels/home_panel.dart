import 'package:flutter/material.dart';
import '../widgets/box_sliver.dart';

class HomePanel extends StatelessWidget {
  const HomePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BoxSliver(
      children: [
        Text('Home'),
      ],
    );
  }
}
