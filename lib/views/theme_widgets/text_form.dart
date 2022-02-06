import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/l10n.dart';
import '../helpers/single_field_form_bloc.dart';
import 'default_input_container.dart';
import 'wrapped_row.dart';

typedef _Bloc = SingleFieldFormBloc<String>;

class TextForm extends StatelessWidget {
  final String label;
  final Future<void> Function() Function(String) onSave;
  final TextStyle? style;
  final bool password;
  final bool resetOnSave;
  final String? saveButtonName;
  final Icon saveButtonIcon;
  final String? saveErrorMessage;

  const TextForm({
    Key? key,
    required this.label,
    required this.onSave,
    this.style,
    this.password = false,
    this.resetOnSave = false,
    this.saveButtonName,
    this.saveButtonIcon = const Icon(Icons.save_alt),
    this.saveErrorMessage,
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
                    builder: (context) => TextField(
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
                                  context
                                      .read<_Bloc>()
                                      .add(SingleFieldFormReset());
                                  resetController(
                                    context.read<_Bloc>().controller,
                                    context.read<_Bloc>().state.initialValue,
                                  );
                                }),
                        errorText: context.watch<_Bloc>().state.validationError,
                      ),
                      style: style,
                      obscureText: password &&
                          !context.watch<_ShowPasswordCubit>().state,
                      onChanged: (value) {
                        context
                            .read<_Bloc>()
                            .add(SingleFieldFormChanged(value));
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                    ),
                  ),
                ),
              ),
              context.read<_Bloc>().state.confermationValidator == null
                  ? TextFormSaveButton(
                      context: context,
                      onSave: onSave,
                      saveButtonName: saveButtonName ?? L10n.of(context)!.save,
                      saveButtonIcon: saveButtonIcon,
                      resetOnSave: resetOnSave,
                    )
                  : const SizedBox(width: 120.0),
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
                      builder: (context) => TextField(
                        controller:
                            context.read<_Bloc>().confirmationController,
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
                                    context
                                        .read<_Bloc>()
                                        .confirmationController
                                        .text = '';
                                    context.read<_Bloc>().add(
                                        SingleFieldFormConfirmationReset());
                                  }),
                          errorText:
                              context.watch<_Bloc>().state.confirmationError,
                        ),
                        style: style,
                        obscureText: password &&
                            !context.watch<_ShowPasswordCubit>().state,
                        onChanged: (value) {
                          context
                              .read<_Bloc>()
                              .add(SingleFieldFormConfirmed(value));
                        },
                      ),
                    ),
                  ),
                ),
                TextFormSaveButton(
                  context: context,
                  onSave: onSave,
                  saveButtonName: saveButtonName ?? L10n.of(context)!.save,
                  saveButtonIcon: saveButtonIcon,
                  resetOnSave: resetOnSave,
                ),
              ],
            ),
          ),
        ],
      );

  VoidCallback onError(
    BuildContext context,
  ) =>
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saveErrorMessage ?? L10n.of(context)!.errorSave(label),
            ),
          ),
        );
      };

  void resetController(
    TextEditingController controller,
    String initialValue,
  ) {
    controller.text = initialValue;
    controller.selection = TextSelection(
      baseOffset: controller.text.length,
      extentOffset: controller.text.length,
    );
  }
}

@visibleForTesting
class TextFormSaveButton extends StatelessWidget {
  final BuildContext context;
  final Future<void> Function() Function(String) onSave;
  final String saveButtonName;
  final Icon saveButtonIcon;
  final bool resetOnSave;

  const TextFormSaveButton({
    Key? key,
    required this.context,
    required this.onSave,
    required this.saveButtonName,
    required this.saveButtonIcon,
    required this.resetOnSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: context.watch<_Bloc>().state.ready &&
                !context.watch<RepositoryRequestBloc>().state
            ? () => context.read<RepositoryRequestBloc>().add(
                  RepositoryRequest(
                    request: () async {
                      await onSave(context.read<_Bloc>().state.value)();
                      if (resetOnSave) {
                        context.read<_Bloc>().add(SingleFieldFormReset());
                      }
                    },
                  ),
                )
            : null,
        label: Text(saveButtonName),
        icon: saveButtonIcon,
      );
}

class _ShowPasswordCubit extends Cubit<bool> {
  _ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}
