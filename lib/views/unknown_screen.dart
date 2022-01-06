import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CenteringColumn(
      children: [
        Text('Unknown'),
      ],
    );
  }
}
