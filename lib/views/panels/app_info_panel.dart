import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/app_info_provider.dart';
import '../widgets.dart';

class AppInfoPanel extends StatelessWidget {
  const AppInfoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(
      builder: (context, appInfo, child) {
        return BoxSliver(
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
        );
      },
    );
  }
}
