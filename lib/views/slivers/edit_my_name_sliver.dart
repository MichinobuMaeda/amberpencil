import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../../services/accounts_service.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class EditMyNameSliver extends StatelessWidget {
  const EditMyNameSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          BlocProvider(
            key: ValueKey(
              '${(EditMyNameSliver).toString()}:name:'
              '${context.watch<AppStateProvider>().me!.name}',
            ),
            create: (context) => SingleFieldFormBloc(
              context.read<AppStateProvider>().me!.name,
              validator: requiredValidator,
            ),
            child: Builder(
              builder: (context) => TextForm(
                label: '表示名',
                onSave: onSaveName(
                  context.read<AppStateProvider>().accountsService,
                  context.read<AppStateProvider>().me!.id,
                ),
              ),
            ),
          ),
        ],
      );
}

TextFormOnSave onSaveName(
  AccountsService accountsService,
  String uid,
) =>
    (String value) async {
      await accountsService.updateAccountProperties(uid, {"name": value});
    };
