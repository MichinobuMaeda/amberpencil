import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/app_state_provider.dart';
import 'widgets.dart';

const List<String> themeModeList = ['自動', 'ライト', 'ダーク'];

class SignOutPanel extends StatelessWidget {
  const SignOutPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WrappedRow(
            children: [
              Text(
                'このアプリの通常の使い方でログアウトする必要はありません。',
                style: TextStyle(color: errorColor(context)),
              ),
            ],
          ),
          WrappedRow(
            children: [
              ComfirmDangerButon(
                context: context,
                message: '本当にログアウトしますか？',
                icon: const Icon(Icons.logout),
                label: 'ログアウト',
                onPressed: () {
                  appState.signOut();
                },
              ),
            ],
          ),
        ],
      );
    });
  }
}
