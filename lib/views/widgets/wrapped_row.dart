part of '../widgets.dart';

class WrappedRow extends Widget {
  final List<Widget> children;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const WrappedRow({
    Key? key,
    required this.children,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Element createElement() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    ).createElement();
  }
}
