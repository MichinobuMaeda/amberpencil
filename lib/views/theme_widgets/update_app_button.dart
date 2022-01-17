import 'package:flutter/material.dart';
import '../../utils/platform_web.dart';

class UpdateAppButton extends StatelessWidget {
  const UpdateAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: const Text(
          'アプリを更新してください',
          textAlign: TextAlign.right,
        ),
        actions: const [
          IconButton(
            onPressed: reloadWebAapp,
            icon: Icon(Icons.system_update),
          )
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber.shade900
            : Colors.amber.shade400,
      );
}
