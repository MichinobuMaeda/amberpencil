import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets/text_form.dart';
import '../widgets/single_field_form_bloc.dart';

class EditMyPasswordSection extends StatelessWidget {
  const EditMyPasswordSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        key: ValueKey('${(EditMyPasswordSection).toString()}:password'),
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
            onSave: onSave(context.read<AppStateProvider>().authService),
          ),
        ),
      );

  Future<void> Function(String) onSave(AuthService authService) =>
      (String value) async {
        await authService.updateMyPassword(value);
        await authService.reload();
      };
}
