import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../blocs/platform_bloc.dart';
import '../theme_widgets/box_sliver.dart';

List<String> themeModeList(BuildContext context) => [
      AppLocalizations.of(context)!.auto,
      AppLocalizations.of(context)!.light,
      AppLocalizations.of(context)!.dark,
    ];

class ThemeModeSliver extends StatelessWidget {
  const ThemeModeSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: List<Widget>.generate(
          themeModeList(context).length,
          (int index) => ChoiceChip(
            label: Text(themeModeList(context)[index]),
            selected: context.select<PlatformBloc, int>(
                    (bloc) => bloc.state.themeMode) ==
                index,
            onSelected: (bool selected) {
              if (selected) {
                context.read<PlatformBloc>().add(ThemeModeChanged(index));
              }
            },
          ),
        ).toList(),
      );
}
