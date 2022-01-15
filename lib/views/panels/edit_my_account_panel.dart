import 'package:amberpencil/services/accounts_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../../utils/interval_notifier.dart';
import '../widgets/box_sliver.dart';
import '../widgets/text_form.dart';
import 'reauthentication_panel.dart';
import 'edit_my_email_panel.dart';
import 'edit_my_password_panel.dart';

TextFormOnSave onSaveDisplayName(
  AccountsService accountsService,
  String uid,
) =>
    (String value) async {
      await accountsService.updateAccountProperties(
        uid,
        {"name": value},
      );
    };

bool isExpired(BuildContext context) {
  int reauthedAtMilliSec =
      context.watch<AppStateProvider>().reauthedAt?.millisecondsSinceEpoch ?? 0;
  bool testMode = context.watch<TestModeState>().testMode;
  return (DateTime.now().millisecondsSinceEpoch - reauthedAtMilliSec) >
      (testMode ? 10 * 1000 : 1800 * 1000);
}

class TestModeState extends ChangeNotifier {
  bool _testMode = false;

  bool get testMode => _testMode;

  set testMode(bool val) {
    _testMode = val;
    notifyListeners();
  }
}

class EditMyAccountPanel extends StatelessWidget {
  const EditMyAccountPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => IntervalNotifier(
                  interval: const Duration(seconds: 10),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => TestModeState(),
              ),
            ],
            child: Builder(
              builder: (context) => Column(
                children: [
                  TextForm(
                    key: const ValueKey('EditMyAccountPanel:DisplayName'),
                    label: '表示名',
                    initialValue: context.watch<AppStateProvider>().me!.name,
                    validator: requiredValidator,
                    onSave: onSaveDisplayName(
                      context.read<AppStateProvider>().accountsService,
                      context.read<AppStateProvider>().me!.id,
                    ),
                  ),
                  Visibility(
                    visible:
                        context.watch<AppStateProvider>().me?.email != null &&
                            isExpired(context),
                    child: const ReauthenticationPanel(),
                  ),
                  Visibility(
                    visible:
                        context.watch<AppStateProvider>().me?.email != null &&
                            !isExpired(context),
                    child: const EditMyEmailPanel(),
                  ),
                  Visibility(
                    visible:
                        context.watch<AppStateProvider>().me?.email != null &&
                            !isExpired(context),
                    child: const EditMyPasswordPanel(),
                  ),
                  Visibility(
                    visible: context.watch<AppStateProvider>().isTest,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Switch(
                          value: context.watch<TestModeState>().testMode,
                          onChanged: (bool value) {
                            context.read<TestModeState>().testMode = value;
                          },
                        ),
                        const Text('Test'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
