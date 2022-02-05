import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/l10n.dart';

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
            Flexible(child: Text(L10n.of(context)!.pleaseWait)),
          ],
        ),
      );
}
