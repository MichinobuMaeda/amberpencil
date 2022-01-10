part of '../widgets.dart';

class WrappedRow extends StatelessWidget {
  final List<Widget> children;
  final double width;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const WrappedRow({
    Key? key,
    required this.children,
    this.width = 720.0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: width),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}
