import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../blocs/my_account_bloc.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/comfirm_danger_buton.dart';
import '../theme_widgets/wrapped_row.dart';

class SignOutSliver extends StatelessWidget {
  const SignOutSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          Column(
            children: [
              WrappedRow(
                children: [
                  Text(
                    AppLocalizations.of(context)!.alertSignOut,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              WrappedRow(
                children: [
                  ComfirmDangerButon(
                    context: context,
                    message: AppLocalizations.of(context)!.confirmSignOut,
                    icon: const Icon(Icons.logout),
                    label: AppLocalizations.of(context)!.signOut,
                    onPressed: () =>
                        context.read<MyAccountBloc>().add(OnSingOutRequired()),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
