import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conf_provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';

class PolicyPanel extends StatelessWidget {
  const PolicyPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfProvider>(
      builder: (context, conf, child) {
        return Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            Future<void> onPolicySave(String value) async {
              try {
                await conf.confService.updateConfProperties(
                  appState.me!.id,
                  {"policy": value},
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '保存できませんでした。'
                      '通信の状態を確認してやり直してください。',
                    ),
                  ),
                );
              }
            }

            return BoxSliver(
              children: [
                WrappedRow(
                  children: [
                    MarkdownForm(
                      label: 'プライバシー・ポリシー',
                      initialValue: conf.data?.policy,
                      editable: appState.me?.admin == true,
                      onSave: onPolicySave,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
