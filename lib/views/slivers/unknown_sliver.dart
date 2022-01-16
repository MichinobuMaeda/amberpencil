import 'package:flutter/material.dart';
import '../widgets/box_sliver.dart';

class UnknownSliver extends StatelessWidget {
  const UnknownSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const BoxSliver(
        children: [
          Text('お探しのデータが見つかりませんでした。'),
        ],
      );
}
