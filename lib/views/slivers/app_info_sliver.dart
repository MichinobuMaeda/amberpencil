import 'package:flutter/material.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../config/l10n.dart';
import '../theme_widgets/box_sliver.dart';

class AppInfoPSliver extends StatelessWidget {
  const AppInfoPSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationIcon: const Image(
                  image: logoAsset,
                  width: baseFontSize * 3,
                  height: baseFontSize * 3,
                ),
                applicationName: appName,
                applicationVersion: version,
                applicationLegalese: copyright,
              );
            },
            icon: const Icon(Icons.copyright),
            label: Text(L10n.of(context)!.copyrightAndLicenses),
          ),
        ],
      );
}
