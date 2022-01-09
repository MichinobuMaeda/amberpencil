import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/validators.dart';
import '../models/app_state_provider.dart';
import 'widgets.dart';

class EditMyPasswordPanel extends StatefulWidget {
  const EditMyPasswordPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditMyPasswordState();
}

class _EditMyPasswordState extends State<EditMyPasswordPanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _value = '';
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      void valueChanged(String value) {
        setState(() {
          _value = value;
          _waiting = false;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
      }

      void confirmationChanged(String value) {
        setState(() {
          _waiting = false;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
      }

      void Function()? onSave =
          (_waiting || _formKey.currentState?.validate() != true)
              ? null
              : () async {
                  setState(() {
                    _waiting = true;
                  });
                  try {
                    await appState.authService.updateMyPassword(_value);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'パスワードが保存できませんでした。'
                          '通信の状態を確認してやり直してください。',
                        ),
                      ),
                    );
                  }
                };

      return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WrappedRow(
              children: [
                DefaultInputContainer(
                  child: PasswordFormField(
                    labelText: 'パスワード',
                    validator: passwordValidator,
                    onChanged: valueChanged,
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                  ),
                ),
              ],
            ),
            WrappedRow(
              alignment: WrapAlignment.end,
              children: [
                DefaultInputContainer(
                  child: PasswordFormField(
                    labelText: '確認',
                    validator: (value) => confermValidator(_value, value),
                    onChanged: confirmationChanged,
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onSave,
                  label: const Text('保存'),
                  icon: const Icon(Icons.save_alt),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
