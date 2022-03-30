import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ToggleEditButton extends StatelessWidget {
  final bool editMode;
  final VoidCallback onEdit;
  final VoidCallback? onClose;
  final Icon icon;

  const ToggleEditButton({
    Key? key,
    required this.editMode,
    required this.onEdit,
    this.icon = const Icon(Icons.description),
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => editMode
      ? IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          color: Theme.of(context).colorScheme.primary,
        )
      : onClose != null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              color: Theme.of(context).colorScheme.primary,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: baseFontSize / 2,
              ),
              child: icon,
            );
}
