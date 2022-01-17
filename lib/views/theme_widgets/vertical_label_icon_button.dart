import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VerticalLabelIconButton extends Widget {
  final String label;
  final Icon icon;
  final void Function()? onPressed;
  final double minWidth;
  final ButtonStyle? style;
  final double? fontSize;

  const VerticalLabelIconButton({
    Key? key,
    required this.label,
    required this.icon,
    this.minWidth = baseFontSize * 4,
    this.onPressed,
    this.style,
    this.fontSize,
  }) : super(key: key);

  @override
  Element createElement() => ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: TextButton(
          onPressed: onPressed,
          style: style,
          child: Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                icon,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).createElement();
}
