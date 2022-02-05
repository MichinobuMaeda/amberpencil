import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/my_account_bloc.dart';
import '../../config/l10n.dart';
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
                    L10n.of(context)!.alertSignOut,
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
                    message: L10n.of(context)!.confirmSignOut,
                    icon: const Icon(Icons.logout),
                    label: L10n.of(context)!.signOut,
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
