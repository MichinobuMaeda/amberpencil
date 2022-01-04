import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessageBar(
  BuildContext context,
  String message, {
  bool? error,
}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextButton.icon(
          label: Text(message),
          icon: const Icon(Icons.close),
          onPressed: () {
            closeMessageBar(context);
          },
          style: ButtonStyle(
            foregroundColor: error == true
                ? MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.error,
                  )
                : null,
          ),
        ),
        duration: const Duration(seconds: 30),
      ),
    );

void closeMessageBar(BuildContext context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
}

class WrappedRow extends StatelessWidget {
  final List<Widget> children;

  const WrappedRow({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        children: children,
      ),
    );
  }
}

class DefaultInputConstrainedBox extends StatelessWidget {
  final Widget child;

  const DefaultInputConstrainedBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(480, 84)),
      child: child,
    );
  }
}
