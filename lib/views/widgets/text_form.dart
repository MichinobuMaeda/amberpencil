import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'default_input_container.dart';
import 'single_field_form_bloc.dart';
import 'wrapped_row.dart';

typedef _State = SingleFieldFormBloc<String>;

typedef TextFormValidate = SingleFieldValidate<String>;
typedef TextFormReset = SingleFieldOnValueReset<String>;
typedef TextFormOnSave = SingleFieldOnSave<String>;

class TextForm extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextFormValidate validator;
  final TextFormOnSave _onSave;
  final TextStyle? style;

  const TextForm({
    Key? key,
    required this.label,
    this.initialValue,
    this.validator,
    required TextFormOnSave onSave,
    this.style,
  })  : _onSave = onSave,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue ?? '');

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
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            context.read<_State>().add(
                                  SingleFieldFormReset(
                                    onReset(controller, initialValue ?? ''),
                                  ),
                                );
                          }),
                      errorText:
                          context.watch<_State>().state.validationErrorMessage,
                    ),
                    style: style,
                    onChanged: (value) {
                      context.read<_State>().add(
                            SingleFieldFormChanged(
                              value,
                              validate: validator,
                              onValueChange: onChange(context),
                            ),
                          );
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: context.watch<_State>().state.buttonEnabled
                      ? () {
                          context.read<_State>().add(
                                SingleFieldFormSave(
                                  _onSave,
                                  onError(context),
                                ),
                              );
                        }
                      : null,
                  label: const Text('保存'),
                  icon: const Icon(Icons.save_alt),
                ),
              ],
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

  VoidCallback onReset(
    TextEditingController controller,
    String initialValue,
  ) =>
      () {
        controller.text = initialValue;
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
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
}
