import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../config/layouts.dart';
import '../models/app_info_provider.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(
      builder: (context, appInfoProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WrappedRow(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showAboutDialog(
                                  context: context,
                                  applicationIcon: const Image(
                                    image: AssetImage('assets/images/logo.png'),
                                    width: 48,
                                    height: 48,
                                  ),
                                  applicationName: appInfoProvider.appInfo.name,
                                  applicationVersion:
                                      appInfoProvider.appInfo.version,
                                  applicationLegalese:
                                      appInfoProvider.appInfo.copyright,
                                );
                              },
                              icon: const Icon(Icons.copyright),
                              label: const Text('著作権'),
                            ),
                          ],
                        ),
                      ),
                      const WrappedRow(
                        children: [
                          Text(
                            'プライバシー・ポリシー',
                            style: TextStyle(fontSize: fontSizeH2),
                          ),
                        ],
                      ),
                      WrappedRow(
                        children: [
                          Html(
                            data: markdown.markdownToHtml(
                                appInfoProvider.appInfo.policy ?? ''),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
