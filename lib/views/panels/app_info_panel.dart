import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../models/conf_provider.dart';
import '../widgets.dart';

class AppInfoPanel extends StatelessWidget {
  const AppInfoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfProvider>(
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
                  applicationName: appName,
                  applicationVersion: version,
                  applicationLegalese: copyright,
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
