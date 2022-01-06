import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/app_state_provider.dart';
import '../utils/ui_utils.dart';

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
              ElevatedButton.icon(
                onPressed: () {
                  appState.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('ログアウト'),
                style: errorElevatedButtonStyle(context),
              ),
            ],
          ),
        ],
      );
    });
  }
}
