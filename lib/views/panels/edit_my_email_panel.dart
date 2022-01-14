import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets/default_input_container.dart';
import '../widgets/wrapped_row.dart';

class EditMyEmailPanel extends StatefulWidget {
  const EditMyEmailPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditMyEmailState();
}

class _EditMyEmailState extends State<EditMyEmailPanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _value = '';
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      final String _current = appState.me!.email!;

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

      void Function()? onSave = (_waiting ||
              _formKey.currentState?.validate() != true ||
              _value == _current)
          ? null
          : () async {
              setState(() {
                _waiting = true;
              });
              try {
                await appState.accountsService.updateAccountProperties(
                  appState.me!.id,
                  {"email": _value},
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'メールが保存できませんでした。'
                      '通信の状態を確認してやり直してください。',
                    ),
                  ),
                );
              }
            };

      const double width = 640.0;

      return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WrappedRow(
              width: width,
              alignment: WrapAlignment.center,
              children: [
                DefaultInputContainer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'メールアドレス'),
                    validator: emailValidator,
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                    onChanged: valueChanged,
                  ),
                ),
                const SizedBox(width: 120.0),
                DefaultInputContainer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '確認'),
                    validator: (value) => confermValidator(_value, value),
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                    onChanged: confirmationChanged,
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
