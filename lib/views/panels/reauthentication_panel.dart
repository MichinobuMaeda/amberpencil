import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';

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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
    }

    void onSendEmailLink() async {
      setState(() {
        _waiting = true;
      });
      try {
        await appState.authService.reauthenticateWithEmail();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${appState.me?.email ?? ''} にメールを送信しました。'
              'メールに記載された手順で再ログインしてください。',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'メールが送信できませんでした。'
              '通信の状態を確認してやり直してください。',
            ),
          ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'パスワードの確認ができませんでした。',
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
          const WrappedRow(
            alignment: WrapAlignment.center,
            width: width * 2 / 3,
            children: [
              Text(
                'メールアドレスまたはパスワードを変更する場合、'
                '現在のメールアドレスまたはパスワードの確認が必要です。',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          WrappedRow(
            alignment: WrapAlignment.center,
            width: width,
            children: [
              OutlinedButton(
                onPressed: onSendEmailLink,
                child: const Text('確認用のURLをメールで受け取る'),
                style: ButtonStyle(minimumSize: buttonMinimumSize),
              ),
            ],
          ),
          WrappedRow(
            width: width,
            alignment: WrapAlignment.center,
            children: [
              DefaultInputContainer(
                child: PasswordFormField(
                  labelText: 'パスワード',
                  onChanged: passwordChanged,
                  validator: requiredValidator,
                  style: const TextStyle(fontFamily: fontFamilyMonoSpace),
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
