import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/l10n.dart';
import '../../config/theme.dart';
import '../helpers/single_field_form_bloc.dart';
import 'default_input_container.dart';
import 'wrapped_row.dart';

typedef _Bloc = SingleFieldFormBloc<String>;

class TextForm extends StatelessWidget {
  final String label;
  final Future<void> Function() Function(String) onSave;
  final TextStyle? style;
  final bool password;
  final String? itemName;
  final String? successMessage;
  final String? errorMessage;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final bool resetOnSave;
  final String? saveButtonName;
  final Icon saveButtonIcon;

  const TextForm({
    Key? key,
    required this.label,
    this.itemName,
    this.successMessage,
    this.errorMessage,
    this.onSuccess,
    this.onError,
    required this.onSave,
    this.style,
    this.password = false,
    this.resetOnSave = false,
    this.saveButtonName,
    this.saveButtonIcon = const Icon(Icons.save_alt),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WrappedRow(
            children: [
              DefaultInputContainer(
                child: BlocProvider(
                  create: (_) => _ShowPasswordCubit(false),
                  child: Builder(
                    builder: (context) => buildTextField(context),
                  ),
                ),
              ),
              context.read<_Bloc>().state.confermationValidator == null
                  ? buildSaveButton(context)
                  : SizedBox(width: buttonMinimumSize.width),
            ],
          ),
          Visibility(
            visible: context.read<_Bloc>().state.confermationValidator != null,
            child: WrappedRow(
              children: [
                DefaultInputContainer(
                  child: BlocProvider(
                    create: (_) => _ShowPasswordCubit(false),
                    child: Builder(
                      builder: (context) => buildConfirmationField(context),
                    ),
                  ),
                ),
                buildSaveButton(context),
              ],
            ),
          ),
        ],
      );

  Widget buildTextField(BuildContext context) => TextField(
        controller: context.read<_Bloc>().controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: password
              ? IconButton(
                  icon: Icon(
                    context.watch<_ShowPasswordCubit>().state
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    context.read<_ShowPasswordCubit>().toggle();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    context.read<_Bloc>().add(SingleFieldFormReset());
                  }),
          errorText: context.watch<_Bloc>().state.validationError,
        ),
        style: style,
        obscureText: password && !context.watch<_ShowPasswordCubit>().state,
        onChanged: (value) {
          context.read<_Bloc>().add(SingleFieldFormChanged(value));
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        },
      );

  Widget buildConfirmationField(BuildContext context) => TextField(
        controller: context.read<_Bloc>().confirmationController,
        decoration: InputDecoration(
          labelText: L10n.of(context)!.confirmation(label),
          suffixIcon: password
              ? IconButton(
                  icon: Icon(
                    context.watch<_ShowPasswordCubit>().state
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    context.read<_ShowPasswordCubit>().toggle();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    context.read<_Bloc>().confirmationController.text = '';
                    context
                        .read<_Bloc>()
                        .add(SingleFieldFormConfirmationReset());
                  }),
          errorText: context.watch<_Bloc>().state.confirmationError,
        ),
        style: style,
        obscureText: password && !context.watch<_ShowPasswordCubit>().state,
        onChanged: (value) {
          context.read<_Bloc>().add(SingleFieldFormConfirmed(value));
        },
      );

  Widget buildSaveButton(BuildContext context) => ElevatedButton.icon(
        onPressed: context.watch<_Bloc>().state.ready &&
                !context.watch<RepositoryRequestBloc>().state
            ? () => context.read<RepositoryRequestBloc>().add(
                  RepositoryRequest(
                    itemName: itemName,
                    successMessage: successMessage,
                    errorMessage: errorMessage,
                    onSuccess: onSuccess,
                    onError: onError,
                    request: () async {
                      await onSave(context.read<_Bloc>().state.value)();
                      if (resetOnSave) {
                        try {
                          context.read<_Bloc>().add(SingleFieldFormReset());
                        } catch (_) {}
                      }
                    },
                  ),
                )
            : null,
        label: Text(saveButtonName ?? L10n.of(context)!.save),
        icon: saveButtonIcon,
      );
}

class _ShowPasswordCubit extends Cubit<bool> {
  _ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}
