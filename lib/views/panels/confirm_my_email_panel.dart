import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../blocs/auth_bloc.dart';
import '../../config/l10n.dart';
import '../theme_widgets/wrapped_row.dart';

class ConfirmMyEmailPanel extends StatelessWidget {
  const ConfirmMyEmailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => WrappedRow(
        children: [
          OutlinedButton(
            onPressed: onSendEmailLink(context),
            child: Text(L10n.of(context)!.reauthWithEmail),
            style: ButtonStyle(minimumSize: buttonMinimumSize),
          ),
        ],
      );

  Future<void> Function() onSendEmailLink(BuildContext context) => () async {
        try {
          await context.read<AuthBloc>().reauthenticateWithEmail();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.sentReauthUrl),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.erroSendEmail),
            ),
          );
        }
      };
}
