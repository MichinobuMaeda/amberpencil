import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'default_input_container.dart';
import 'single_field_form_bloc.dart';
import 'wrapped_row.dart';
import 'password_field.dart';

typedef _State = SingleFieldFormBloc<String>;

typedef TextFormValidate = SingleFieldValidate<String>;
typedef TextFormOnSave = SingleFieldOnSave<String>;

class TextForm extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextFormValidate validator;
  final TextFormOnSave _onSave;
  final TextStyle? style;
  final bool password;
  final bool withConfirmation;

  const TextForm({
    Key? key,
    required this.label,
    this.initialValue,
    this.validator,
    required TextFormOnSave onSave,
    this.style,
    this.password = false,
    this.withConfirmation = false,
  })  : _onSave = onSave,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue ?? '');
    final confirmationController = TextEditingController(text: '');

    return BlocProvider(
      key: ValueKey(
          'ProviderOf:TextForm:${key.toString()}:${initialValue ?? ''}'),
      create: (context) => SingleFieldFormBloc<String>(initialValue ?? ''),
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WrappedRow(
              alignment: WrapAlignment.center,
              children: [
                DefaultInputContainer(
                  child: password
                      ? PasswordField(
                          controller: controller,
                          labelText: label,
                          style: style,
                          errorText:
                              context.watch<_State>().state.validationError,
                          onChanged: (value) {
                            context.read<_State>().add(
                                  SingleFieldFormChanged(
                                    value,
                                    validator: validator,
                                    onValueChange: onChange(context),
                                  ),
                                );
                          },
                        )
                      : TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: label,
                            suffixIcon: IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  context
                                      .read<_State>()
                                      .add(SingleFieldFormReset());
                                  resetController(
                                    controller,
                                    initialValue ?? '',
                                  );
                                }),
                            errorText:
                                context.watch<_State>().state.validationError,
                          ),
                          style: style,
                          onChanged: (value) {
                            context.read<_State>().add(
                                  SingleFieldFormChanged(
                                    value,
                                    validator: validator,
                                    onValueChange: onChange(context),
                                  ),
                                );
                          },
                        ),
                ),
                withConfirmation
                    ? const SizedBox(width: 120.0)
                    : TextFormSaveButton(
                        onSave: _onSave,
                        onError: onError(context),
                      ),
              ],
            ),
            Visibility(
              visible: withConfirmation,
              child: WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  DefaultInputContainer(
                    child: password
                        ? PasswordField(
                            controller: confirmationController,
                            labelText: '確認',
                            style: style,
                            errorText:
                                context.watch<_State>().state.validationError,
                            onChanged: (value) {
                              context.read<_State>().add(
                                    SingleFieldFormConfirmed(value),
                                  );
                            },
                          )
                        : TextField(
                            controller: confirmationController,
                            decoration: InputDecoration(
                              labelText: '確認',
                              suffixIcon: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    confirmationController.text = '';
                                    context.read<_State>().add(
                                        SingleFieldFormConfirmationReset());
                                  }),
                              errorText:
                                  context.watch<_State>().state.validationError,
                            ),
                            style: style,
                            onChanged: (value) {
                              context.read<_State>().add(
                                    SingleFieldFormConfirmed(value),
                                  );
                            },
                          ),
                  ),
                  TextFormSaveButton(
                    onSave: _onSave,
                    onError: onError(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback onChange(
    BuildContext context,
  ) =>
      () {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      };

  VoidCallback onError(
    BuildContext context,
  ) =>
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存できませんでした。通信の状態を確認してやり直してください。'),
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

class TextFormSaveButton extends StatelessWidget {
  final TextFormOnSave _onSave;
  final VoidCallback _onError;

  const TextFormSaveButton({
    Key? key,
    required TextFormOnSave onSave,
    required VoidCallback onError,
  })  : _onSave = onSave,
        _onError = onError,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: context.watch<_State>().state.buttonEnabled
          ? () {
              context.read<_State>().add(
                    SingleFieldFormSave(
                      _onSave,
                      _onError,
                    ),
                  );
            }
          : null,
      label: const Text('保存'),
      icon: const Icon(Icons.save_alt),
    );
  }
}
