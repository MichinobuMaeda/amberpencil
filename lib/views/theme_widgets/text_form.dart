import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'default_input_container.dart';
import '../helpers/single_field_form_bloc.dart';
import 'wrapped_row.dart';

typedef _Bloc = SingleFieldFormBloc<String>;

typedef TextFormOnSave = SingleFieldOnSave<String>;

class TextForm extends StatelessWidget {
  final String label;
  final TextFormOnSave _onSave;
  final TextStyle? style;
  final bool password;
  final String saveButtonName;
  final Icon saveButtonIcon;
  final String saveErrorMessage;

  const TextForm({
    Key? key,
    required this.label,
    required TextFormOnSave onSave,
    this.style,
    this.password = false,
    this.saveButtonName = '保存',
    this.saveButtonIcon = const Icon(Icons.save_alt),
    String? saveErrorMessage,
  })  : _onSave = onSave,
        saveErrorMessage = saveErrorMessage ??
            '$labelが保存できませんでした。'
                '通信の状態を確認してやり直してください。',
        super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WrappedRow(
            children: [
              DefaultInputContainer(
                child: BlocProvider(
                  create: (_) => ShowPasswordCubit(false),
                  child: Builder(
                    builder: (context) => TextField(
                      controller: context.read<_Bloc>().controller,
                      decoration: InputDecoration(
                        labelText: label,
                        suffixIcon: password
                            ? IconButton(
                                icon: Icon(
                                  context.watch<ShowPasswordCubit>().state
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  context.read<ShowPasswordCubit>().toggle();
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
                      obscureText:
                          password && !context.watch<ShowPasswordCubit>().state,
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
                      onSave: _onSave,
                      onError: onError(context),
                      saveButtonName: saveButtonName,
                      saveButtonIcon: saveButtonIcon,
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
                    create: (_) => ShowPasswordCubit(false),
                    child: Builder(
                      builder: (context) => TextField(
                        controller:
                            context.read<_Bloc>().confirmationController,
                        decoration: InputDecoration(
                          labelText: '$labelの確認',
                          suffixIcon: password
                              ? IconButton(
                                  icon: Icon(
                                    context.watch<ShowPasswordCubit>().state
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    context.read<ShowPasswordCubit>().toggle();
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
                            !context.watch<ShowPasswordCubit>().state,
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
                  onSave: _onSave,
                  onError: onError(context),
                  saveButtonName: saveButtonName,
                  saveButtonIcon: saveButtonIcon,
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
            content: Text(saveErrorMessage),
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
  final TextFormOnSave onSave;
  final VoidCallback onError;
  final String saveButtonName;
  final Icon saveButtonIcon;

  const TextFormSaveButton({
    Key? key,
    required this.onSave,
    required this.onError,
    required this.saveButtonName,
    required this.saveButtonIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: context.watch<_Bloc>().state.buttonEnabled
            ? () {
                context.read<_Bloc>().add(
                      SingleFieldFormSave(onSave, onError),
                    );
              }
            : null,
        label: Text(saveButtonName),
        icon: saveButtonIcon,
      );
}

@visibleForTesting
class ShowPasswordCubit extends Cubit<bool> {
  ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}
