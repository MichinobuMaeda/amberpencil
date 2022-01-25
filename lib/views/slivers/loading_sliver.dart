import 'package:amberpencil/config/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LoadingSliver extends StatelessWidget {
  const LoadingSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: baseFontSize * 4,
              height: baseFontSize * 4,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: spacing * 2),
            Flexible(child: Text(AppLocalizations.of(context)!.pleaseWait)),
          ],
        ),
      );
}
