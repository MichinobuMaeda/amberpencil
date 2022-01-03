import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_route.dart';
import '../models/app_state_provider.dart';

class EmailVerifyScreen extends StatelessWidget {
  final AppRoute route;
  const EmailVerifyScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStateProvider appStateModel =
        Provider.of<AppStateProvider>(context, listen: false);
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            await appStateModel.authService.sendEmailVerification();
          },
          child: const Text('Verify'),
        ),
        ElevatedButton(
          onPressed: () async {
            await appStateModel.authService.reload();
          },
          child: const Text('Reload'),
        ),
        ElevatedButton(
          onPressed: () async {
            await appStateModel.authService.signOut();
          },
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
