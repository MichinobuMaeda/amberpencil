import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/conf_provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/markdown_form.dart';
import '../widgets/wrapped_row.dart';

Future<void> Function(String) onSave(
  BuildContext context,
  String? uid,
) =>
    (String value) async {
      assert(uid != null, 'Before sign-in.');
      await context.read<ConfProvider>().confService.updateConfProperties(
        uid!,
        {"policy": value},
      );
    };

class PolicyPanel extends StatelessWidget {
  const PolicyPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          WrappedRow(
            children: [
              MarkdownForm(
                label: 'プライバシー・ポリシー',
                initialValue: context.watch<ConfProvider>().data?.policy ?? '',
                editable: context.watch<AppStateProvider>().me?.admin == true,
                onSave: onSave(
                  context,
                  context.watch<AppStateProvider>().me?.id,
                ),
                style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                markdownStyleSheet: markdownStyleSheet(context),
              ),
            ],
          ),
        ],
      );
}
