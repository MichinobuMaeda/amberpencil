import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';

class LoadingSliver extends StatelessWidget {
  const LoadingSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: baseFontSize * 4,
              height: baseFontSize * 4,
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: spacing * 2),
            Flexible(child: Text('しばらくお待ちください')),
          ],
        ),
      );
}
