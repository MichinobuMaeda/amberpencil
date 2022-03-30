import 'package:flutter/material.dart';
import '../../config/l10n.dart';
import '../theme_widgets/box_sliver.dart';

class UnknownSliver extends StatelessWidget {
  const UnknownSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          Text(L10n.of(context)!.notFound),
        ],
      );
}
