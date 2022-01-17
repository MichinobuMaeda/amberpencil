import 'package:amberpencil/services/conf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../models/conf_provider.dart';
import '../../models/app_state_provider.dart';
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
                  '${context.watch<ConfProvider>().data?.policy}',
                ),
                create: (context) => SingleFieldFormBloc(
                  context.read<ConfProvider>().data?.policy ?? '',
                  withEditMode: true,
                ),
                child: Builder(
                  builder: (context) => MultiLineTextForm(
                    label: 'プライバシー・ポリシー',
                    onSave: onSave(
                      context.read<ConfProvider>().confService,
                      context.watch<AppStateProvider>().me?.id,
                    ),
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
  ConfService confService,
  String? uid,
) =>
    (String value) async {
      assert(uid != null, 'Before sign-in.');
      await confService.updateConfProperties(
        uid!,
        {"policy": value},
      );
    };
