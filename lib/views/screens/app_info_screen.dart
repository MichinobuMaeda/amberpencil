import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/app_info_provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';
import '../edit_markdown_panel.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(
      builder: (context, appInfo, child) {
        return Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            Future<void> onPolicySave(String value) async {
              try {
                await appState.confService.updateConfProperties(
                  appState.me!.id!,
                  {"policy": value},
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'メールが保存できませんでした。'
                      '通信の状態を確認してやり直してください。',
                    ),
                  ),
                );
              }
            }

            return SliverToBoxAdapter(
              child: CenteringColumn(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationIcon: const Image(
                              image: logoAsset,
                              width: 48,
                              height: 48,
                            ),
                            applicationName: appInfo.data.name,
                            applicationVersion: appInfo.data.version,
                            applicationLegalese: appInfo.data.copyright,
                          );
                        },
                        icon: const Icon(Icons.info),
                        label: const Text('著作権とライセンス'),
                      ),
                    ],
                  ),
                  EditMarkdownPanel(
                    label: 'プライバシー・ポリシー',
                    initialValue: appInfo.data.policy,
                    editable: appState.me?.admin == true,
                    onSave: onPolicySave,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
