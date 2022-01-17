import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PageTitileSliver extends StatelessWidget {
  final String title;
  final Widget icon;
  const PageTitileSliver({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.all(spacing / 4),
        sliver: SliverToBoxAdapter(
          child: ColoredBox(
            color: Theme.of(context).backgroundColor,
            child: Wrap(
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
        ),
      );
}
