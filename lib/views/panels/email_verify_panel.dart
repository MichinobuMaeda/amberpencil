import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/wrapped_row.dart';

class EmailVerifyPanel extends StatefulWidget {
  const EmailVerifyPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerifyPanel> {
  bool _send = false;
  late Timer timer;
  void Function()? reload;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (reload != null) {
          reload!();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);
    reload ??= () {
      appState.authService.reload();
    };

    const double width = 480.0;

    return BoxSliver(
      children: [
        Column(
          children: [
            WrappedRow(
              alignment: WrapAlignment.center,
              width: width,
              children: [
                Text(
                  '初めて使うメールアドレスの確認が必要です。'
                  '下の「送信」ボタンを押してください。'
                  '${appState.me!.email} に確認のためのメールを送信しますので、'
                  'そのメールに記載された確認のためのボタンを押してください。',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            WrappedRow(
              alignment: WrapAlignment.center,
              width: width,
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
            if (_send)
              const WrappedRow(
                alignment: WrapAlignment.center,
                width: width,
                children: [
                  Text(
                    '確認のためのメールを送信しました。'
                    'そのメールに記載された確認のためのボタンを押しても'
                    'この表示が自動で切り替わらない場合は'
                    '下の「更新」ボタンを押してください。',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            if (_send)
              WrappedRow(
                alignment: WrapAlignment.center,
                width: width,
                children: [
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text('更新'),
                  ),
                ],
              ),
            const WrappedRow(
              alignment: WrapAlignment.center,
              width: width,
              children: [
                Text(
                  'メールアドレスを修正してやり直す場合はログアウトしてください。',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            WrappedRow(
              alignment: WrapAlignment.center,
              width: width,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await appState.signOut();
                  },
                  child: const Text('ログアウト'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
