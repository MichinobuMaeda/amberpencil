import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/l10n.dart';

class ToggleDeleteRestoreButton extends StatelessWidget {
  final bool deleted;
  final String collection;
  final String item;
  final Future<void> Function() onDelete;
  final Future<void> Function() onRestore;

  const ToggleDeleteRestoreButton({
    Key? key,
    required this.deleted,
    required this.collection,
    required this.item,
    required this.onDelete,
    required this.onRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TextButton.icon(
        icon: Icon(
          deleted ? Icons.restore_from_trash : Icons.remove,
        ),
        label: Text(
          deleted ? L10n.of(context)!.restore : L10n.of(context)!.delete,
        ),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.error,
          ),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              deleted
                  ? L10n.of(context)!.confirmRestore(collection, item)
                  : L10n.of(context)!.confirmDelete(collection, item),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(L10n.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => context.read<RepositoryRequestBloc>().add(
                      RepositoryRequest(
                        request: deleted ? onRestore : onDelete,
                      ),
                    ),
                child: Text(
                  deleted
                      ? L10n.of(context)!.restore
                      : L10n.of(context)!.delete,
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
