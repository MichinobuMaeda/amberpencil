import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';

class SignInPanel extends StatefulWidget {
  const SignInPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignInPanel> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    void emailChanged(String value) {
      setState(() {
        _email = value;
        _waiting = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
    }

    void passwordChanged(String value) {
      setState(() {
        _password = value;
        _waiting = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
    }

    void Function()? onSendEmailLink = (_waiting ||
            _emailFormKey.currentState?.validate() != true ||
            _email == '')
        ? null
        : () async {
            setState(() {
              _waiting = true;
            });
            try {
              await appState.authService.sendSignInLinkToEmail(
                _email,
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
          };

    void Function()? onSendEmailAndPassword = (_waiting ||
            _emailFormKey.currentState?.validate() != true ||
            _email == '' ||
            _password == '')
        ? null
        : () async {
            setState(() {
              _waiting = true;
            });
            try {
              await appState.authService.signInWithEmailAndPassword(
                _email,
                _password,
              );
              appState.updateSignedInAt();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ログインできませんでした。'
                    'メールアドレスとパスワードを確認してやり直してください。',
                  ),
                ),
              );
            }
          };

    return BoxSliver(
      children: [
        Form(
          key: _emailFormKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  DefaultInputContainer(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                      validator: emailValidator,
                      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                      onChanged: emailChanged,
                    ),
                  ),
                ],
              ),
              WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onSendEmailLink,
                    child: const Text('ログイン用のURLをメールで受け取る'),
                    style: ButtonStyle(minimumSize: buttonMinimumSize),
                  ),
                ],
              ),
              WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  DefaultInputContainer(
                    child: PasswordFormField(
                      labelText: 'パスワード',
                      onChanged: passwordChanged,
                      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                    ),
                  ),
                ],
              ),
              WrappedRow(
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onSendEmailAndPassword,
                    child: const Text('メールアドレスとパスワードでログインする'),
                    style: ButtonStyle(minimumSize: buttonMinimumSize),
                  ),
                ],
              ),
              if (appState.isTest)
                WrappedRow(
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await appState.authService.signInWithEmailAndPassword(
                          'primary@example.com',
                          'password',
                        );
                      },
                      child: const Text('Test'),
                      style: secondaryElevatedButtonStyle,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
