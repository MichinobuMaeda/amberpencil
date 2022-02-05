import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/l10n.dart';
import '../helpers/single_field_form_bloc.dart';

typedef _Bloc = SingleFieldFormBloc<String>;

class TextFormDialog extends StatelessWidget {
  final String initialValue;
  final String label;
  final String? Function(String?)? validator;
  final Future<void> Function() Function(String) onSave;

  const TextFormDialog({
    Key? key,
    required this.initialValue,
    required this.label,
    this.validator,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => _Bloc(
          initialValue,
          validator: validator,
        ),
        child: Builder(
          builder: (context) => AlertDialog(
            content: TextField(
              controller: context.read<_Bloc>().controller,
              decoration: InputDecoration(
                labelText: label,
                errorText: context.watch<_Bloc>().state.validationError,
              ),
              onChanged: (String value) {
                context.read<_Bloc>().add(SingleFieldFormChanged(value));
              },
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
                            request: onSave(context.read<_Bloc>().state.value),
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
