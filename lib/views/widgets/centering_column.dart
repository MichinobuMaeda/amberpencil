part of '../widgets.dart';

class CenteringColumn extends Widget {
  final List<Widget> children;
  final double width;

  const CenteringColumn({
    Key? key,
    required this.children,
    this.width = 960.0,
  }) : super(key: key);

  @override
  Element createElement() {
    return Flex(
      direction: Axis.vertical,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: width),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    ).createElement();
  }
}
