import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
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
            label: Text(AppLocalizations.of(context)!.copyrightAndLicenses),
          ),
        ],
      );
}
