import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/platform_repository.dart';

class UpdateAppButton extends StatelessWidget {
  const UpdateAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: const Text(
          'アプリを更新してください',
          textAlign: TextAlign.right,
        ),
        actions: [
          IconButton(
            onPressed: context.read<PlatformRepository>().reloadWebAapp,
            iconSize: baseFontSize * 2,
            icon: Ink(
              padding: const EdgeInsets.all(4.0),
              decoration: ShapeDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                shape: const CircleBorder(),
              ),
              child: Icon(
                Icons.get_app,
                size: 24.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.amber.shade900
                    : Colors.white,
              ),
            ),
          )
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber.shade900
            : Colors.amber.shade400,
      );
}
