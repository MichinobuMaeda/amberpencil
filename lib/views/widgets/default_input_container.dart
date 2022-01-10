part of '../widgets.dart';

class DefaultInputContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const DefaultInputContainer({
    Key? key,
    required this.child,
    this.width = 480.0,
    this.height = 84.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(width, height)),
      child: child,
    );
  }
}
