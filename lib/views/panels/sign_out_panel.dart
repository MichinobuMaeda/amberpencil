import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/comfirm_danger_buton.dart';

class SignOutPanel extends StatelessWidget {
  const SignOutPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      return BoxSliver(
        children: [
          Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              Text(
                'このアプリの通常の使い方でログアウトする必要はありません。',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
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
