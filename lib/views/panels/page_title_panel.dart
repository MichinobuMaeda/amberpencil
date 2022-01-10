import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PageTitilePanel extends StatelessWidget {
  final String title;
  final Widget icon;
  const PageTitilePanel({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: Theme.of(context).backgroundColor,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: fontSizeH2 * 1.6,
              height: fontSizeH2 * 1.6,
              child: icon,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: fontSizeH2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
