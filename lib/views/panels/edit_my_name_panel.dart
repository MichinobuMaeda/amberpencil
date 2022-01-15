import 'package:amberpencil/services/accounts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/text_form.dart';

TextFormOnSave onSaveName(
  AccountsService accountsService,
  String uid,
) =>
    (String value) async {
      await accountsService.updateAccountProperties(
        uid,
        {"name": value},
      );
    };

class EditMyNamePanel extends StatelessWidget {
  const EditMyNamePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          TextForm(
            key: const ValueKey('EditMyAccountPanel:DisplayName'),
            label: '表示名',
            initialValue: context.watch<AppStateProvider>().me!.name,
            validator: requiredValidator,
            onSave: onSaveName(
              context.read<AppStateProvider>().accountsService,
              context.read<AppStateProvider>().me!.id,
            ),
          ),
        ],
      );
}
