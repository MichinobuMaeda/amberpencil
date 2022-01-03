import 'package:flutter/material.dart';

class ScrollScreen extends StatelessWidget {
  final Widget child;
  const ScrollScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (BuildContext context) {
          return LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
