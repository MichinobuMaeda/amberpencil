import 'package:flutter/material.dart';
import '../widgets/box_sliver.dart';

class UnknownPanel extends StatelessWidget {
  const UnknownPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BoxSliver(
      children: [
        Text('お探しのデータが見つかりませんでした。'),
      ],
    );
  }
}
