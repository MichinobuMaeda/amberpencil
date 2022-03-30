import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../router.dart';
import '../helpers/sticky_header_delegate.dart';

class PageTitileSliver extends StatelessWidget {
  const PageTitileSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageItem item = getPage(context, GoRouter.of(context).location);

    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: fontSizeH2 * 1.6,
        maxHeight: fontSizeH2 * 2.2,
        child: Container(
          color: Theme.of(context).colorScheme.primary.withOpacity(1 / 4),
          child: Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: fontSizeH2 * 1.6,
                  height: fontSizeH2 * 1.6,
                  child: item.icon,
                ),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: fontSizeH2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
