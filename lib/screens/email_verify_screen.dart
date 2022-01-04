import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state_provider.dart';
import '../config/layouts.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerifyScreen> {
  bool _send = false;

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WrappedRow(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WrappedRow(
                    children: [
                      Text(
                        '初めて使うメールアドレスの確認が必要です。'
                        '下の「送信」ボタンを押してください。'
                        '${appState.me!.email} に確認のためのメールを送信しますので、'
                        'そのメールに記載された確認のためのボタンを押してください。',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await appState.authService.sendEmailVerification();
                            setState(() {
                              _send = true;
                            });
                          },
                          label: const Text('送信'),
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                  if (_send)
                    const WrappedRow(
                      children: [
                        Text(
                          '確認のためのメールを送信しました。'
                          'そのメールに記載された確認のためのボタンを押しても'
                          'この表示が自動で切り替わらない場合は'
                          '下の「更新」ボタンを押してください。',
                        ),
                      ],
                    ),
                  if (_send)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await appState.authService.reload();
                            },
                            child: const Text('更新'),
                          ),
                        ],
                      ),
                    ),
                  const WrappedRow(
                    children: [
                      Text('メールアドレスを修正してやり直す場合はログアウトしてください。'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await appState.authService.signOut();
                          },
                          child: const Text('ログアウト'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
