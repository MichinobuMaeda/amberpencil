import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';
import 'reauthentication_panel.dart';
import 'edit_my_email_panel.dart';
import 'edit_my_password_panel.dart';

class EditMyAccountPanel extends StatefulWidget {
  const EditMyAccountPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditMyAccountState();
}

class _EditMyAccountState extends State<EditMyAccountPanel> {
  late Timer timer;
  bool _test = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      final bool autExpired = (DateTime.now().millisecondsSinceEpoch -
              (appState.reauthedAt?.millisecondsSinceEpoch ?? 0)) >
          (_test ? 10 * 1000 : 1800 * 1000);

      return BoxSliver(
        children: [
          Column(
            children: [
              TextForm(
                label: '表示名',
                initialValue: appState.me!.name,
                validator: requiredValidator,
                onSave: (String value) async {
                  appState.accountsService.updateAccountProperties(
                    appState.me!.id,
                    {"name": value},
                  );
                },
              ),
              if (appState.me?.email != null && autExpired)
                const ReauthenticationPanel(),
              if (appState.me?.email != null && !autExpired)
                const EditMyEmailPanel(),
              if (appState.me?.email != null && !autExpired)
                const EditMyPasswordPanel(),
              if (appState.isTest)
                Switch(
                  value: _test,
                  onChanged: (bool value) {
                    setState(() {
                      _test = value;
                    });
                  },
                ),
              const Text('Test')
            ],
          ),
        ],
      );
    });
  }
}
