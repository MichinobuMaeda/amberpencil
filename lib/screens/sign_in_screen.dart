import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/layouts.dart';
import '../config/validators.dart';
import '../models/app_state_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _hidePassword = true;
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    void emailChanged(String value) {
      setState(() {
        _email = value;
        _waiting = false;
        closeMessageBar(context);
      });
    }

    void passwordChanged(String value) {
      setState(() {
        _password = value;
        _waiting = false;
        closeMessageBar(context);
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
              showMessageBar(
                context,
                'メールが送信できませんでした。'
                '通信の状態を確認してやり直してください。',
                error: true,
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
            } catch (e) {
              showMessageBar(
                context,
                'ログインできませんでした。'
                'メールアドレスとパスワードを確認してやり直してください。',
                error: true,
              );
            }
          };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const WrappedRow(
          children: [
            Icon(Icons.login, size: fontSizeH2 * 1.6),
            Text(
              'ログイン',
              style: TextStyle(fontSize: fontSizeH2),
            )
          ],
        ),
        Form(
          key: _emailFormKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WrappedRow(
                children: [
                  DefaultInputConstrainedBox(
                    child: TextFormField(
                      key: const ValueKey('SignInScreen:Email'),
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                      validator: (value) => emailValidator(value ?? ''),
                      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                      onChanged: emailChanged,
                    ),
                  ),
                ],
              ),
              WrappedRow(
                children: [
                  OutlinedButton(
                    onPressed: onSendEmailLink,
                    child: const Text('ログイン用のURLをメールで受け取る'),
                    style: ButtonStyle(minimumSize: buttonMinimumSize),
                  ),
                ],
              ),
              WrappedRow(
                children: [
                  DefaultInputConstrainedBox(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'パスワード',
                          suffixIcon: IconButton(
                            icon: Icon(_hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          )),
                      obscureText: _hidePassword,
                      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                      onChanged: passwordChanged,
                    ),
                  ),
                ],
              ),
              WrappedRow(
                children: [
                  OutlinedButton(
                    onPressed: onSendEmailAndPassword,
                    child: const Text('メールアドレスとパスワードでログインする'),
                    style: ButtonStyle(minimumSize: buttonMinimumSize),
                  ),
                ],
              ),
            ],
          ),
        ),
        WrappedRow(
          children: [
            ElevatedButton(
              onPressed: () async {
                await appState.authService.signInWithEmailAndPassword(
                  'primary@example.com',
                  'password',
                );
              },
              child: const Text('Test'),
            ),
          ],
        ),
      ],
    );
  }
}
