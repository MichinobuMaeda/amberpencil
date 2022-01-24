import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../helpers/sticky_header_delegate.dart';

class SectionHeaderSliver extends StatelessWidget {
  final String title;

  const SectionHeaderSliver(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: true,
        delegate: StickyHeaderDelegate(
          minHeight: fontSizeH3 * 1.5,
          maxHeight: fontSizeH3 * 2,
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: fontSizeH3),
              ),
            ),
          ),
        ),
      );
}
