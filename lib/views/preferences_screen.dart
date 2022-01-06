import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state_provider.dart';
import '../utils/ui_utils.dart';
import 'theme_mode_panel.dart';
import 'edit_my_account_panel.dart';
import 'sign_out_panel.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child) {
      return CenteringColumn(
        children: [
          const ThemeModePanel(),
          if (appState.me != null) const EditMyAccountPanel(),
          if (appState.me != null) const SignOutPanel(),
        ],
      );
    });
  }
}
