import 'package:flutter/material.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../widgets/box_sliver.dart';

class AppInfoPanel extends StatelessWidget {
  const AppInfoPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
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
            icon: const Icon(Icons.copyright),
            label: const Text('著作権とライセンス'),
          ),
        ],
      );
}
