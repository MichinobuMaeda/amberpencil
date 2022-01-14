import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'default_input_container.dart';
import 'single_field_form_state.dart';
import 'wrapped_row.dart';

typedef _OnSaveCallBack = OnFormSaveCallBack<String>;
typedef _State = SingleFieldFormState<String>;

VoidCallback onChange(BuildContext context) => () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    };

VoidCallback onError(BuildContext context) => () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存できませんでした。通信の状態を確認してやり直してください。'),
        ),
      );
    };

class TextForm extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final _OnSaveCallBack _onSave;
  final TextStyle? style;

  const TextForm({
    Key? key,
    required this.label,
    this.initialValue,
    this.validator,
    required _OnSaveCallBack onSave,
    this.style,
  })  : _onSave = onSave,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey('ProviderOf:TextForm:$label:$initialValue'),
      create: (context) => _State(
        formKey: GlobalKey<FormState>(),
        initialValue: initialValue ?? '',
        onChange: onChange(context),
      ),
      child: Builder(
        builder: (context) => Form(
          key: context.read<_State>().formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  DefaultInputContainer(
                    child: TextFormField(
                      initialValue: context.read<_State>().initialValue,
                      decoration: InputDecoration(
                        labelText: label,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: context.read<_State>().reset,
                        ),
                      ),
                      validator: validator,
                      style: style,
                      onChanged: context.read<_State>().setValue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: context.watch<_State>().save(
                          onSave: _onSave,
                          onError: onError(context),
                        ),
                    label: const Text('保存'),
                    icon: const Icon(Icons.save_alt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
