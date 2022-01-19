import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../repositories/auth_repository.dart';
import '../theme_widgets/wrapped_row.dart';

class ConfirmMyEmailPanel extends StatelessWidget {
  const ConfirmMyEmailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WrappedRow(
        children: [
          OutlinedButton(
            onPressed: onSendEmailLink(context),
            child: const Text('確認用のURLをメールで受け取る'),
            style: ButtonStyle(minimumSize: buttonMinimumSize),
          ),
        ],
      );

  Future<void> Function() onSendEmailLink(BuildContext context) => () async {
        try {
          await context.read<AuthRepository>().reauthenticateWithEmail();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '登録されたアドレスにメールを送信しました。'
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
      };
}
