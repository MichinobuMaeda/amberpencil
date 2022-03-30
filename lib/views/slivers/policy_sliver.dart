import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/conf_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../config/theme.dart';
import '../../config/l10n.dart';
import '../../models/conf.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/multi_line_text_form.dart';
import '../helpers/single_field_form_bloc.dart';
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
                  '$runtimeType:policy:'
                  '${context.select<ConfBloc, String?>(
                    (confBloc) => confBloc.state?.policy,
                  )}',
                ),
                create: (context) => SingleFieldFormBloc(
                  context.read<ConfBloc>().state?.policy ?? '',
                  withEditMode: true,
                ),
                child: Builder(
                  builder: (context) => MultiLineTextForm(
                    label: L10n.of(context)!.privacyPolicy,
                    onSave: (value) => () => context.read<ConfBloc>().update({
                          Conf.fieldPolicy: value,
                        }),
                    style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                    markdown: true,
                    editable: context.watch<UserBloc>().state.me?.admin == true,
                    markdownStyleSheet: markdownStyleSheet(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
