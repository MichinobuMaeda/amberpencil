import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/l10n.dart';
import '../helpers/single_field_form_bloc.dart';

typedef _Bloc = SingleFieldFormBloc<List<String>>;

class ListViewItem {
  final String value;
  final String title;

  ListViewItem({
    required this.value,
    required this.title,
  });
}

class TextListFieldDialog extends StatelessWidget {
  final List<String> initialValue;
  final List<ListViewItem> items;
  final String label;
  final Future<void> Function() Function(List<String>) onSave;

  const TextListFieldDialog({
    Key? key,
    required this.initialValue,
    required this.items,
    required this.label,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => _Bloc(initialValue),
        child: Builder(
          builder: (context) => AlertDialog(
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                children: items
                    .map(
                      (item) => CheckboxListTile(
                        onChanged: (value) {
                          if (value == true) {
                            context.read<_Bloc>().add(
                                  SingleFieldFormChanged(
                                    [
                                      ...context.watch<_Bloc>().state.value,
                                      item.value,
                                    ],
                                  ),
                                );
                          } else {
                            context.read<_Bloc>().add(
                                  SingleFieldFormChanged(
                                    context
                                        .watch<_Bloc>()
                                        .state
                                        .value
                                        .where((value) => value != item.value)
                                        .toList(),
                                  ),
                                );
                          }
                        },
                        value: context
                            .watch<_Bloc>()
                            .state
                            .value
                            .contains(item.value),
                        title: Text(item.title),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(L10n.of(context)!.cancel),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color?>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: context.watch<_Bloc>().state.ready &&
                        !context.watch<RepositoryRequestBloc>().state
                    ? () => context.read<RepositoryRequestBloc>().add(
                          RepositoryRequest(
                            request: onSave(context.watch<_Bloc>().state.value),
                            onSuccess: () => Navigator.pop(context),
                          ),
                        )
                    : null,
                child: Text(L10n.of(context)!.save),
              ),
            ],
          ),
        ),
      );
}
