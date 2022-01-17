import 'package:flutter/material.dart';
import '../theme_widgets/box_sliver.dart';

class HomeSliver extends StatelessWidget {
  const HomeSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const BoxSliver(
        children: [
          Text('Home'),
        ],
      );
}
