import 'package:flutter/material.dart';
import '../../config/theme.dart';

class WrappedRow extends StatelessWidget {
  final List<Widget> children;
  final double width;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const WrappedRow({
    Key? key,
    required this.children,
    this.width = pageWidth,
    this.alignment = WrapAlignment.center,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: spacing / 2),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: alignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          ),
        ),
      );
}
