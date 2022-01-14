import 'package:flutter/material.dart';

class ComfirmDangerButon extends Widget {
  final BuildContext context;
  final String message;
  final String label;
  final Icon icon;
  final void Function()? onPressed;

  const ComfirmDangerButon({
    Key? key,
    required this.context,
    required this.message,
    required this.label,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Element createElement() {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            actions: [
              TextButton.icon(
                label: Text(label),
                icon: icon,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
                onPressed: onPressed,
              ),
              TextButton.icon(
                label: const Text('中止'),
                icon: const Icon(Icons.close),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
      icon: icon,
      label: Text(label),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.error,
        ),
      ),
    ).createElement();
  }
}
