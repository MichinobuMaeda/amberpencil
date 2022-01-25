import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme_widgets/box_sliver.dart';

class UnknownSliver extends StatelessWidget {
  const UnknownSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          Text(AppLocalizations.of(context)!.notFound),
        ],
      );
}
