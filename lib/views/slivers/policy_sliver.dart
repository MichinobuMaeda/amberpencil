import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/conf_bloc.dart';
import '../../config/theme.dart';
import '../../models/conf.dart';
import '../../repositories/conf_repository.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/multi_line_text_form.dart';
import '../theme_widgets/single_field_form_bloc.dart';
import '../theme_widgets/wrapped_row.dart';

class PolicySliver extends StatelessWidget {
  const PolicySliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          WrappedRow(
            children: [
              BlocProvider(
                key: ValueKey(
                  '${(PolicySliver).toString()}:policy:'
                  '${context.watch<PolicyCubit>().state}',
                ),
                create: (context) => SingleFieldFormBloc(
                  context.read<PolicyCubit>().state,
                  withEditMode: true,
                ),
                child: Builder(
                  builder: (context) => MultiLineTextForm(
                    label: 'プライバシー・ポリシー',
                    onSave: onSave(context.read<ConfRepository>()),
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                    markdown: true,
                    markdownStyleSheet: markdownStyleSheet(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

Future<void> Function(String) onSave(
  ConfRepository confRepository,
) =>
    (String value) async {
      await confRepository.updateField(
        {Conf.fieldPolicy: value},
      );
    };
