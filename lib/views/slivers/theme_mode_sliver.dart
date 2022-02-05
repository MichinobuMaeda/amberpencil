import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/accounts_bloc.dart';
import '../../blocs/my_account_bloc.dart';
import '../../blocs/platform_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/app_info.dart';
import '../../config/l10n.dart';
import '../../models/account.dart';
import '../../utils/env.dart';
import '../theme_widgets/box_sliver.dart';

List<String> themeModeList(BuildContext context) => [
      L10n.of(context)!.auto,
      L10n.of(context)!.light,
      L10n.of(context)!.dark,
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
                onSelected: (bool selected) {
                  if (selected) {
                    if (context.read<MyAccountBloc>().state.me == null) {
                      context.read<PlatformBloc>().add(
                            ThemeModeChanged(index == 0 ? 3 : index),
                          );
                    } else {
                      context.read<RepositoryRequestBloc>().add(
                            RepositoryRequest(
                              request: () =>
                                  context.read<AccountsBloc>().updateMyAccount({
                                Account.fieldThemeMode: index == 0 ? 3 : index,
                              }),
                              item: L10n.of(context)!.themeMode,
                              onSuccess: () {},
                            ),
                          );
                    }
                  }
                }),
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
