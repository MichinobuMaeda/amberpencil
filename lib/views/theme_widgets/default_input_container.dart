import 'package:flutter/widgets.dart';
import '../../config/theme.dart';

class DefaultInputContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const DefaultInputContainer({
    Key? key,
    required this.child,
    this.width = fieldWidth,
    this.height = baseFontSize * 5.25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints.tight(Size(width, height)),
        child: child,
      );
}
