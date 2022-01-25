import 'package:amberpencil/blocs/accounts_bloc.dart';
import 'package:amberpencil/blocs/my_account_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../blocs/platform_bloc.dart';
import '../../config/app_info.dart';
import '../../models/account.dart';
import '../../utils/env.dart';
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
        children: [
          ...List<Widget>.generate(
            themeModeList(context).length,
            (int index) => ChoiceChip(
              label: Text(themeModeList(context)[index]),
              selected: context.select<PlatformBloc, int>(
                      (bloc) => bloc.state.themeMode) ==
                  (index == 0 ? 3 : index),
              onSelected: context.watch<MyAccountBloc>().state.me == null
                  ? (bool selected) {
                      if (selected) {
                        context.read<PlatformBloc>().add(
                              ThemeModeChanged(index == 0 ? 3 : index),
                            );
                      }
                    }
                  : (bool selected) {
                      if (selected) {
                        context.read<AccountsBloc>().add(
                              MyAccountChanged(
                                Account.fieldThemeMode,
                                index == 0 ? 3 : index,
                                () {},
                              ),
                            );
                      }
                    },
            ),
          ).toList(),
          if (isTestMode(version))
            ActionChip(
              label: const Text('Reset'),
              // ignore: invalid_use_of_visible_for_testing_member
              onPressed: () => context.read<PlatformBloc>().add(
                    ThemeModeReseted(),
                  ),
            ),
        ],
      );
}
