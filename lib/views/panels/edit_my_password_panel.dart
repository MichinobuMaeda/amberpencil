import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../repositories/auth_repository.dart';
import '../theme_widgets/text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class EditMyPasswordPanel extends StatelessWidget {
  const EditMyPasswordPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('${(EditMyPasswordPanel).toString()}:password'),
        create: (context) => SingleFieldFormBloc(
          '',
          validator: passwordValidator,
          confermationValidator: confermationValidator,
        ),
        child: Builder(
          builder: (context) => TextForm(
            label: 'パスワード',
            password: true,
            style: const TextStyle(fontFamily: fontFamilyMonoSpace),
            onSave: onSave(context.read<AuthRepository>()),
          ),
        ),
      );

  Future<void> Function(String) onSave(AuthRepository authRepository) =>
      (String value) async {
        await authRepository.updateMyPassword(value);
      };
}
