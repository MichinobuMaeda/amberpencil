import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

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
