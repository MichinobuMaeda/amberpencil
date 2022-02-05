import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../blocs/auth_bloc.dart';
import '../../config/l10n.dart';
import '../theme_widgets/text_form.dart';
import '../helpers/single_field_form_bloc.dart';

class EditMyPasswordPanel extends StatelessWidget {
  const EditMyPasswordPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('$runtimeType:password'),
        create: (context) => SingleFieldFormBloc(
          '',
          validator: passwordValidator(context),
          confermationValidator: confermationValidator(context),
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: L10n.of(context)!.password,
            password: true,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            onSave: (value) => () async {
              await context.read<AuthBloc>().updateMyPassword(value);
              // context.read<SingleFieldFormBloc>().add(SingleFieldFormReset());
            },
          ),
        ),
      );
}
