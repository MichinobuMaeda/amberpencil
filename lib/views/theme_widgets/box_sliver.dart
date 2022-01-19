import 'package:flutter/widgets.dart';
import '../../config/theme.dart';

class BoxSliver extends StatelessWidget {
  final List<Widget> children;

  const BoxSliver({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.all(spacing / 2),
        sliver: SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: children,
          ),
        ),
      );
}
