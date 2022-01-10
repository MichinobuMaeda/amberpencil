part of '../widgets.dart';

class BoxSliver extends StatelessWidget {
  final List<Widget> children;

  const BoxSliver({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          runSpacing: 16.0,
          children: children,
        ),
      ),
    );
  }
}
