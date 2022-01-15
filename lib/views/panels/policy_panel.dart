import 'package:amberpencil/services/conf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/conf_provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/multi_line_text_form.dart';
import '../widgets/wrapped_row.dart';

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

class PolicyPanel extends StatelessWidget {
  const PolicyPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          WrappedRow(
            children: [
              MultiLineTextForm(
                key: const ValueKey('PolicyPanel:DisplayName'),
                label: 'プライバシー・ポリシー',
                initialValue: context.watch<ConfProvider>().data?.policy ?? '',
                onSave: onSave(
                  context.read<ConfProvider>().confService,
                  context.watch<AppStateProvider>().me?.id,
                ),
                style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                markdown: true,
                markdownStyleSheet: markdownStyleSheet(context),
              ),
            ],
          ),
        ],
      );
}