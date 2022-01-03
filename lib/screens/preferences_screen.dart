import 'package:flutter/material.dart';
import '../screens/scroll_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScrollScreen(
      child: Text('Preferences'),
    );
  }
}
