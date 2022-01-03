import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_route.dart';
import '../models/app_state_provider.dart';

class SignInScreen extends StatelessWidget {
  final AppRoute route;
  const SignInScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStateProvider appStateModel =
        Provider.of<AppStateProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () async {
        await appStateModel.authService.signInWithEmailAndPassword(
          'primary@example.com',
          'password',
        );
      },
      child: const Text('Test'),
    );
  }
}
