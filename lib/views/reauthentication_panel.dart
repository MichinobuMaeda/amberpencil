import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/ui_utils.dart';
import '../config/validators.dart';
import '../models/app_state_provider.dart';

class ReauthenticationPanel extends StatefulWidget {
  const ReauthenticationPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReauthenticationState();
}

class _ReauthenticationState extends State<ReauthenticationPanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password = '';
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    void passwordChanged(String value) {
      setState(() {
        _password = value;
        _waiting = false;
        closeMessageBar(context);
      });
    }

    void onSendEmailLink() async {
      setState(() {
        _waiting = true;
      });
      try {
        await appState.authService.reauthenticateWithEmail();
      } catch (e) {
        showMessageBar(
          context,
          'メールが送信できませんでした。'
          '通信の状態を確認してやり直してください。',
          error: true,
        );
      }
    }

    void Function()? onSendEmailAndPassword = (_waiting ||
            _formKey.currentState?.validate() != true ||
            _password == '')
        ? null
        : () async {
            setState(() {
              _waiting = true;
            });
            try {
              await appState.authService.reauthenticateWithPassword(
                _password,
              );
              appState.updateSignedInAt();
            } catch (e) {
              showMessageBar(
                context,
                'パスワードの確認ができませんでした。',
                error: true,
              );
            }
          };

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WrappedRow(
            children: [
              Text('メールアドレスまたはパスワードを変更する場合、'
                  '現在のメールアドレスまたはパスワードの確認が必要です。'),
            ],
          ),
          WrappedRow(
            children: [
              OutlinedButton(
                onPressed: onSendEmailLink,
                child: const Text('確認用のURLをメールで受け取る'),
                style: ButtonStyle(minimumSize: buttonMinimumSize),
              ),
            ],
          ),
          WrappedRow(
            alignment: WrapAlignment.end,
            children: [
              InputContainer(
                child: PasswordFormField(
                  labelText: 'パスワード',
                  onChanged: passwordChanged,
                  validator: requiredValidator,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onSendEmailAndPassword,
                label: const Text('確認'),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
